# See My IP - 프로젝트 계획서

## 1. 프로젝트 개요

**프로젝트명:** See My IP
**목적:** macOS 메뉴바에서 내 컴퓨터의 IP 정보를 빠르고 편리하게 확인할 수 있는 네이티브 앱
**플랫폼:** macOS (메뉴바 상주 앱)

---

## 2. 핵심 기능

### 2.1 메뉴바 메인 화면
- **공인 IP 표시**: 현재 공인(Public) IP 주소 표시 (예: `180.67.63.187`)
- **안내 메시지**: "This is your public IP, all websites see it" 형태의 설명 문구
- **Refresh it**: 공인 IP를 수동으로 새로고침
- **Copy it**: 공인 IP를 클립보드에 복사
- **국가 정보**: 공인 IP 기반 국가 표시 (예: `Country: South Korea`)
- **로컬 IP 표시**: 네트워크 인터페이스별 사설(Local) IP 표시 (예: `en0: 10.0.0.138`)
- **About / Preferences / Quit** 메뉴

### 2.2 로그인 시 자동 시작
- "Start at login" 옵션으로 macOS 부팅 시 자동 실행

---

## 3. 환경설정 (Preferences)

### 3.1 IPv4 포맷 설정
IP 주소의 프라이버시 보호를 위한 마스킹 옵션:
| 옵션 | 표시 예시 | 설명 |
|------|-----------|------|
| full | `255.255.255.255` | 전체 표시 |
| Hidden | 완전 숨김 | IP 숨김 |
| first 2 octets | `255.255....` | 앞 2자리만 표시 |
| last 2 octets | `...255.255` | 뒤 2자리만 표시 |
| first and last octet | `255...255` | 첫째/마지막만 표시 |

### 3.2 IPv6 포맷 설정
IPv6 주소 마스킹 옵션:
| 옵션 | 표시 예시 | 설명 |
|------|-----------|------|
| full | `2001:db8:1234:ffff:ffff::1` | 전체 표시 |
| Hidden | 완전 숨김 | IP 숨김 |
| first 2 non-zero segments | `2001:db8:...` | 앞 2세그먼트 |
| last 2 non-zero segments | `...::1:1` | 뒤 2세그먼트 |
| first 2 and last 1 non-zero segments | `2001:db8:...:1` | 앞 2 + 뒤 1 세그먼트 |

### 3.3 국가 정보 포맷 설정
| 옵션 | 설명 |
|------|------|
| Hidden | 국가 정보 숨김 |
| Emoji flag | 국기 이모지로 표시 |
| Country Code | 국가 코드로 표시 (예: KR) |

### 3.4 IP 자동 갱신 주기
- Off / 1분 / 5분(기본값) / 15분 선택 가능
- 네트워크 인터페이스 변경 감지 시 자동 업데이트 (Wi-Fi 변경, VPN 연결 등)
- 네트워크 변경 알림이 누락될 수 있으므로 백그라운드 주기적 체크 병행

### 3.5 알림 설정
- **Notify when public IP changes**: 공인 IP 변경 시 알림
- **Play sound for notifications**: 알림 시 사운드 재생

---

## 4. 기술 구현 계획

### 4.1 기술 스택
| 항목 | 기술 |
|------|------|
| 언어 | Swift |
| UI 프레임워크 | SwiftUI / AppKit (메뉴바) |
| 최소 지원 버전 | macOS 13+ (Ventura) |
| 빌드 도구 | Xcode / Swift Package Manager |

### 4.2 아키텍처 구성요소

```
[MenuBar StatusItem]
       |
  [Main Menu View]
       |
  +---------+-----------+------------+
  |         |           |            |
[IP       [Local IP   [Country    [Preferences
 Service]  Monitor]    Lookup]     Window]
```

- **IPService**: 외부 API를 통해 공인 IP 조회 (예: `api.ipify.org`, `ifconfig.me`)
- **LocalIPMonitor**: `NWPathMonitor`를 사용한 네트워크 인터페이스 감지 및 사설 IP 조회
- **CountryLookup**: IP Geolocation API를 통한 국가 정보 조회 (예: `ip-api.com`)
- **PreferencesManager**: `UserDefaults` 기반 설정 저장/관리
- **NotificationManager**: 공인 IP 변경 감지 시 macOS 알림 발송

### 4.3 주요 구현 사항
1. **NSStatusItem**: 메뉴바 아이콘 및 팝업 메뉴 구성
2. **NSMenu / NSPopover**: 메인 IP 정보 표시 UI
3. **Timer + NWPathMonitor**: 주기적 IP 갱신 + 네트워크 변경 감지
4. **LaunchAtLogin**: `SMAppService` 또는 `ServiceManagement` 프레임워크를 통한 로그인 시 자동 시작
5. **NSPasteboard**: 클립보드 복사 기능
6. **UNUserNotificationCenter**: IP 변경 알림

---

## 5. 데이터 흐름

```
앱 시작
  -> NWPathMonitor 시작 (네트워크 변경 감지)
  -> 공인 IP 조회 (HTTP API)
  -> 국가 정보 조회 (HTTP API)
  -> 로컬 IP 조회 (시스템 인터페이스)
  -> 메뉴바 UI 갱신

주기적 갱신 (Timer)
  -> 공인 IP 재조회
  -> 이전 IP와 비교
  -> 변경 시 알림 발송 + UI 갱신

네트워크 변경 감지
  -> 모든 IP 정보 재조회
  -> UI 갱신
```

---

## 6. 화면 구성 요약

| 화면 | 설명 |
|------|------|
| 메뉴바 아이콘 | 상시 메뉴바에 표시되는 앱 아이콘 |
| 메인 메뉴 | 공인 IP, 국가, 로컬 IP, Refresh/Copy 버튼 |
| Preferences 창 | IPv4/IPv6 포맷, 국가 포맷, 갱신 주기, 알림 설정 |

---

## 7. 향후 확장 가능 기능
- 여러 공인 IP 조회 API 지원 (fallback)
- VPN 연결 상태 감지 및 표시
- IP 변경 이력 로그
- 메뉴바 아이콘에 국기 이모지 표시
- 다국어 지원 (한국어, 영어 등)
