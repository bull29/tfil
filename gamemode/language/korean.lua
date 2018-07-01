print('kohere')
local locale = {}
local LanguageCode = "ko"
--Following ISO_3166-1 https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

locale.joinPrefix = ""
locale.joinSuffix = " 님이 서버에 접속했습니다!"
locale.leavePrefix = ""
locale.leaveSuffixAfterName = " 님이 서버를 떠났습니다."
locale.leaveSuffixAfterReason = ""
locale.enterPrefix = ""
locale.enterSuffix = " 님이 서버에 접속했습니다!"

locale.gamestart = "라운드가 시작되었습니다! 바닥이 용암이야!!"
locale.winnerPrefix = ""
locale.winnerSuffix = " 님이 이겼습니다!"
locale.winnerByDefaultPrefix = ""
locale.winnerByDefaultSuffix = " 님이 기본 설정에 의해 이겼습니다!"
locale.snooze = "낮잠"
locale.preround = "준비 시간"
locale.started = "진행중"
locale.ended = "쉬는 시간"

locale.unstuckCooltime = "조금만 있다가 다시 시도해주세요."
locale.unstuckStopMoving = "움직임을 멈춰주세요."
locale.unstuckNotStuck = "끼어있지 않습니다."

locale.mapvoteSuccess = "투표가 완료되어 곧 맵 투표가 시작됩니다."
locale.mapvoteRockPrefix = ""
locale.mapvoteRockSuffixAfterNickname = " 님이 투표를 하셨습니다. ("
locale.mapvoteRockBetweenNumericCount = "/"
locale.mapvoteRockSuffix = ")"

locale.mapvoteRockReasonCooltime = "조금만 기다려주세요."
locale.mapvoteRockReasonInVoting = "이미 투표가 진행중입니다."
locale.mapvoteRockReasonVoted = "이미 투표에 참여하셨습니다."
locale.mapvoteRockReasonChangingMaps = "이미 투표가 완료되어 다음 라운드에 맵이 교체됩니다!"
locale.mapvoteRockReasonLeastPlayers = "투표하려면 더 많은 인원이 필요합니다."

locale.helpscreenTitle = "튜토리얼"
locale.helpscreenHelpKey = "F2를 눌러 다시 이 화면을 끄거나 킬수 있습니다."

locale.helpscreenCurrentAbility = "<<< 당신의 현재 능력 (C를 눌러 바꾸세요)"

locale.helpscreenNumOfEggs = "가지고 있는 계란의 개수. >>>"
locale.helpscreenThrowEgg = "마우스 우클릭으로 계란을 던져 방해하세요."
locale.helpscreenBonusWhenHitPlayer = "Gain bonus eggs by successfully hitting players."

locale.helpscreenCurrentRoundTimer = "The current round timer. >>>"
locale.helpscreenThisIsNotAClock = "This is not a clock."

locale.helpscreenCurrentRoundState = "The current round state. >>>"

locale.helpscreenCurrentElevationFromTheLava = "<<< Your current elevation from the Lava in meters"

locale.helpscreenCurrentRankingRelativeOthers = "<<< Your current ranking relative to other players based on your height from the lava."

locale.helpscreenHealth = "Your health percentage"
locale.helpscreenHealthBubblesTail = "vvv"

locale.helpscreenContextMenuAndWidget = "<<< Hold C to access the context menu and widgets."

locale.helpscreenEmojiSense = "Hold Q to access EmojiSense mode."
locale.helpscreenZoom = "Use your +zoom bind for enhanced zooming."


locale.mutatorsShouldStartAMutator = "돌연변이 라운드를 시작할까요? 주사위를 굴려봐요!"
locale.mutatorsLetsMutatePrefix = "주사위의 눈금은 "
locale.mutatorsLetsMutateAnd = " 그리고 "
locale.mutatorsLetsMutateSuffix = " 였습니다! 돌연변이 라운드가 시작됩니다!"
locale.mutatorsNoMutatePrefix = "주사위의 눈금은 "
locale.mutatorsNoMutateAnd = " 그리고 "
locale.mutatorsNoMutateSuffix = " 였습니다! 이번에는 아니네요..."


locale.mutatorsHasBegunPrefix = ""
locale.mutatorsHasBegunSuffix = " 돌연변이 라운드가 시작되었습니다!"
locale.mutatorsIsFlamerPrefix = ""
locale.mutatorsIsFlamerSuffix = " 님이 화염인간입니다! 가까이 가보세요!"

locale.abilityYourNewPrefix = ""
locale.abilityYourNewSuffix = " 능력이 적용되었습니다."

lang_data[ LanguageCode ]  = locale