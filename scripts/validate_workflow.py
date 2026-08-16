from pathlib import Path

workflow = Path('.github/workflows/ios.yml').read_text()
required_tokens = [
    'runs-on: macos-14',
    'actions/checkout@v4',
    'brew install xcodegen',
    'xcodegen generate',
    'generic/platform=iOS Simulator',
    'actions/upload-artifact@v4',
]
missing = [token for token in required_tokens if token not in workflow]
if missing:
    raise SystemExit(f'missing workflow tokens: {missing}')
if workflow.count('name:') < 3:
    raise SystemExit('workflow appears truncated')
print('workflow_structure=ok')
print(f'workflow_lines={len(workflow.splitlines())}')
