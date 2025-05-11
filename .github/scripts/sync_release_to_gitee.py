import os
import requests
import time
import sys
from pathlib import Path

def get_env_var(name, required=True):
    value = os.environ.get(name)
    if required and not value:
        print(f"缺少环境变量: {name}")
        sys.exit(1)
    return value

GITEE_TOKEN = get_env_var('GITEE_TOKEN')
GITHUB_TOKEN = get_env_var('GITHUB_TOKEN')
GITEE_OWNER = get_env_var('GITEE_OWNER')
GITEE_REPO = get_env_var('GITEE_REPO')
GITHUB_REPOSITORY = get_env_var('GITHUB_REPOSITORY')
VERSION = get_env_var('VERSION')

try:
    GITHUB_OWNER, GITHUB_REPO = GITHUB_REPOSITORY.split('/')
except Exception:
    print("GITHUB_REPOSITORY 格式应为 'owner/repo'")
    sys.exit(1)

GITHUB_API = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/tags/v{VERSION}"
GITEE_API = f"https://gitee.com/api/v5/repos/{GITEE_OWNER}/{GITEE_REPO}/releases"

def get_github_release():
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    try:
        response = requests.get(GITHUB_API, headers=headers, timeout=10)
    except Exception as e:
        print(f"请求 GitHub API 失败: {e}")
        sys.exit(1)
    if response.status_code != 200:
        print(f"获取 GitHub Release 失败: {response.text}")
        sys.exit(1)
    return response.json()

def create_gitee_release(github_release):
    check_url = f"{GITEE_API}/tags/v{VERSION}"
    check_params = {"access_token": GITEE_TOKEN}
    check_response = requests.get(check_url, params=check_params, timeout=10)
    if check_response.status_code == 200:
        print(f"Gitee 上已存在 v{VERSION} Release，将先删除")
        release_id = check_response.json().get('id')
        if not release_id:
            print(f"查找 Release ID 失败: {check_response.text}")
            sys.exit(1)
        delete_url = f"{GITEE_API}/{release_id}"
        delete_params = {"access_token": GITEE_TOKEN}
        delete_response = requests.delete(delete_url, params=delete_params, timeout=10)
        if delete_response.status_code != 204:
            print(f"删除已有 Release 失败: {delete_response.text}")
            sys.exit(1)
        time.sleep(5)
    elif check_response.status_code != 404:
        print(f"检查 Gitee Release 状态异常: {check_response.text}")
        sys.exit(1)

    data = {
        "access_token": GITEE_TOKEN,
        "tag_name": f"v{VERSION}",
        "name": github_release.get("name", f"v{VERSION}"),
        "body": github_release.get("body", ""),
        "prerelease": str(github_release.get("prerelease", False)).lower(),
        "target_commitish": "master"
    }

    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = requests.post(GITEE_API, data=data, timeout=10)
            if response.status_code == 201:
                return response.json()
            else:
                print(f"创建 Gitee Release 失败 (尝试 {attempt+1}/{max_retries}): {response.text}")
                if attempt < max_retries - 1:
                    time.sleep(5)
        except Exception as e:
            print(f"请求发生错误 (尝试 {attempt+1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                time.sleep(5)
    print("创建 Gitee Release 失败，达到最大重试次数")
    sys.exit(1)

def upload_assets_to_gitee(gitee_release, assets_dir):
    assets_path = Path(assets_dir)
    if not assets_path.exists() or not assets_path.is_dir():
        print(f"资源目录 {assets_dir} 不存在或不是目录，跳过上传附件。")
        return

    assets_files = list(assets_path.glob('*'))

    if not assets_files:
        print("未找到任何资源文件，无需上传。")
        return

    for asset_file in assets_files:
        print(f"正在上传: {asset_file.name}")

        upload_url = f"{GITEE_API}/{gitee_release['id']}/attachments"
        max_retries = 3
        for attempt in range(max_retries):
            try:
                with open(asset_file, 'rb') as f:
                    files = {'file': (asset_file.name, f)}
                    data = {'access_token': GITEE_TOKEN}
                    response = requests.post(upload_url, files=files, data=data, timeout=30)
                if response.status_code == 201:
                    print(f"上传成功: {asset_file.name}")
                    break
                else:
                    print(f"上传失败 (尝试 {attempt+1}/{max_retries}): {response.text}")
                    if attempt < max_retries - 1:
                        time.sleep(5)
            except Exception as e:
                print(f"上传发生错误 (尝试 {attempt+1}/{max_retries}): {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(5)
        else:
            print(f"上传 {asset_file.name} 失败，达到最大重试次数")

def main():
    print(f"\n[{time.strftime('%Y-%m-%d %H:%M:%S')}] 开始同步 Release v{VERSION} 到 Gitee...")
    github_release = get_github_release()
    print("获取 GitHub Release 信息成功")

    gitee_release = create_gitee_release(github_release)
    print(f"创建 Gitee Release 成功: {gitee_release.get('url', '未知URL')}")

    print("开始上传资源文件...")
    upload_assets_to_gitee(gitee_release, "release-assets")
    print("同步完成!\n")

if __name__ == "__main__":
    main()