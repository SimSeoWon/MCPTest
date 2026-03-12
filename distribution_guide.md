# UE Crash Analyzer - 배포 가이드

기획팀, 아트팀, QA 분들이 파이썬 환경 설정의 번거로움 없이 바로 크래시를 분석하실 수 있도록 단일 실행 파일(`.exe`)로 묶는 방법과 배포 안내입니다.

## 1. 빌드 (exe 파일 생성) 방법
해당 스크립트가 위치한 폴더(`c:\Users\USER\Documents\ModularStage\.claude\mcp`)에 **`build_mcp.bat`** 파일을 만들어 두었습니다!
이 파일을 더블 클릭하여 실행하기만 하면 빌드가 자동으로 진행됩니다.

*   과정 중 자동으로 `PyInstaller`를 설치하고 스크립트를 독립된 실행 파일 하나로 압축합니다.
*   빌드가 완료되면 **`dist`** 라는 새 폴더가 생기며, 이 안에 `UE_Crash_Analyzer.exe` 가 단일 묶음으로 생성됩니다.

## 2. 배포 및 사용 방법 (팀원)
생성된 위 **`UE_Crash_Analyzer.exe` 파일 하나만** 기획자/아트 팀원분들의 PC나 공용 드라이브(Z: 드라이브 등)에 배포하시면 됩니다.

파이썬 환경 설정이나 복잡한 과정 없이, 팀원분들이 사용하시는 AI 에이전트 클라이언트에 맞게 아래 방법으로 등록해주시면 즉시 연동되어 분석 요청이 가능해집니다.

### 🤖 AI 자동 등록 프롬프트 (가장 쉬운 방법)
이 `distribution_guide.md` 파일과 `UE_Crash_Analyzer.exe`를 함께 제공하면서 아래 문장을 복사해서 AI 클라이언트(Antigravity 또는 Claude)에게 붙여넣기 해보세요. AI가 가이드 문서를 읽어보고 스스로, 혹은 가장 편한 방법으로 설정을 도와줍니다.

> **"첨부한 이 distribution_guide.md 파일 내용을 읽고, 내 PC(또는 현재 환경)에 UE_Crash_Analyzer.exe 파일 경로를 잡아서 이 문서에 적힌대로 MCP 서버(`ue-crash-analyzer`)로 자동 등록 세팅을 진행해줘. 파일의 전체 절대 경로는 {여기에 exe 파일 경로 입력} 이야."**

직접 수동으로 등록하시려면 아래의 각 클라이언트별 안내를 따라주세요.

### 🔌 Antigravity (안티그래비티)에 수동으로 MCP 등록하기
Antigravity 역시 표준 MCP(Model Context Protocol)를 완벽하게 지원하므로 손쉽게 연동할 수 있습니다.

1. Antigravity 우측 하단의 **[Settings(톱니바퀴) 아이콘]** 클릭 > **[MCP Servers]** 탭으로 이동합니다.
2. **[Add Server]** 버튼을 누르고 아래와 같이 입력합니다.
   * **Name**: `ue-crash-analyzer` (원하는 이름으로 지정 가능)
   * **Command**: 배포받은 `UE_Crash_Analyzer.exe` 파일의 전체(절대) 경로
     *(예: `Z:\Shared\Tools\UE_Crash_Analyzer.exe`)*
   * **Args**: (빈칸 유지)
3. 등록 완료 후 상태가 연결됨(Connected/초록불)으로 표시되면 정상 연동된 것입니다!
*(파이썬 코드를 직접 실행하시는 경우에는 Command에 `python`, Args에 `uelog_analyzer.py 경로`를 넣으셔도 됩니다.)*

### 🔌 Claude Desktop에 수동으로 MCP 등록하기
데스크탑 앱의 설정 파일(`claude_desktop_config.json`)을 수정하여 등록합니다.

1. Claude Desktop 앱을 열고 메뉴의 **[Settings]** > **[Developer]** > **[Edit Config]** 버튼을 클릭하여 설정 파일을 엽니다.
2. 파일 내용에 아래와 같이 서버 정보를 추가합니다:
```json
{
  "mcpServers": {
    "ue-crash-analyzer": {
      "command": "배포받은_exe_파일의_절대_경로.exe",
      "args": []
    }
  }
}
```
3. 파일을 저장한 후, **Claude Desktop 앱을 완전히 껐다가 다시 실행(Restart)** 하시면 우측 하단 툴셋 아이콘에 `ue-crash-analyzer`가 추가됩니다.
> [!CAUTION]
> 분석 대상인 덤프 파일을 디버깅하기 위해 사용하는 **Windows Debugger (`cdb.exe`)** 는 스크립트에 내장할 수 없기 때문에, 분석을 수행하실 크루원(기획/아트)의 PC에도 최소한 **`Windows SDK` (Debugging Tools for Windows 항목만 포함)** 가 설치되어 있어야 합니다.

## 3. 분석툴 사용 방법 및 파라미터 안내
MCP 연동이 완료되면 AI 에이전트(Claude 등)에게 크래시 및 덤프 분석을 지시할 수 있습니다. 에이전트가 사용하는 툴과 활용 가능한 상세 파라미터는 다음과 같습니다.

### 🔍 툴 1: 최신 크래시 로그 분석 (`get_latest_ue_crash_log`)
가장 최근에 발생한 언리얼 엔진 크래시 로그(.log)와 Diagnostics.txt를 추출하는 기능입니다.
* **`project_dir` (선택)**: 언리얼 프로젝트의 최상위 경로 단위 (예: `D:/MyGame`). 이 경로 안의 `Saved/Crashes` 폴더에서 가장 최신 크래시를 찾습니다.
* **`explicit_crash_dir` (선택)**: 특정 크래시 폴더를 지정하고 싶을 때 사용 (예: `D:/MyGame/Saved/Crashes/UECC-Windows-xxxx`). 이 값을 넣으면 `project_dir`은 무시됩니다.

**사용 예시 대화:**
> *"D:/Project/MyGame 경로에서 최근에 발생한 언리얼 크래시 로그 분석해줘."*

### 🔍 툴 2: 크래시 덤프(.dmp) 정밀 분석 (`analyze_ue_dump`)
Windows SDK의 디버거(`cdb.exe`)를 활용해 콜스택 및 버그 체크 내역을 정밀하게 분석합니다. 보통 툴 1로 원인 파악이 힘들 때 사용합니다.
* **`dump_file_path` (필수)**: 분석할 덤프 파일(`.dmp`)의 전체(절대) 경로.
* **`project_dir` (선택)**: 언리얼 프로젝트의 최상위 경로 (예: `D:/MyGame`). 로컬 빌드 파일(PDB 등)을 덤프 분석과 매핑할 때 사용됩니다.
* **`team_symbol_server_path` (선택)**: 팀에서 사용하는 네트워크 심볼 서버 캐시 또는 빌드 저장소 경로 (예: `Z:/Builds/Symbols` 또는 `SRV*C:/symcache*...`). 정확한 메모리/함수 콜스택 추적에 필요합니다.

**사용 예시 대화:**
> *"오류가 난 덤프 파일 경로가 D:/Temp/UE4Minidump.dmp 인데, Z:/Builds/Symbols 네트워크 드라이브의 심볼(PDB)을 연결해서 원인이 뭔지 분석해줄래?"*
