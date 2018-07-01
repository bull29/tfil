print('enhere')
local locale = {}
local LanguageCode = "en"
--Following ISO_3166-1 https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

locale.joinPrefix = ""
locale.joinSuffix = " has connected to the server!"
locale.leavePrefix = ""
locale.leaveSuffixAfterName = " has left the server."
locale.leaveSuffixAfterReason = ""
locale.enterPrefix = ""
locale.enterSuffix = " has entered the server!"

locale.gamestart = "The Round has Started! The Floor is Lava!"
locale.winnerPrefix = ""
locale.winnerSuffix = " has won!"
locale.winnerByDefaultPrefix = ""
locale.winnerByDefaultSuffix = " has won by default!"
locale.snooze = "Snooze"
locale.preround = "Preparation"
locale.started = "In Progress"
locale.ended = "Postround"

locale.unstuckCooltime = "Please wait a little before attempting to use unstuck again."
locale.unstuckStopMoving = "Please stop moving."
locale.unstuckNotStuck = "You are not stuck."

locale.mapvoteSuccess = "The vote has been rocked, map vote imminent"
locale.mapvoteRockPrefix = ""
locale.mapvoteRockSuffixAfterNickname = " has voted to Rock the Vote. ("
locale.mapvoteRockBetweenNumericCount = "/"
locale.mapvoteRockSuffix = ")"

locale.mapvoteRockReasonCooltime = "You must wait a bit before voting!"
locale.mapvoteRockReasonInVoting = "There is currently a vote in progress!"
locale.mapvoteRockReasonVoted = "You have already voted to Rock the Vote!"
locale.mapvoteRockReasonChangingMaps = "There has already been a vote, the map is going to change!"
locale.mapvoteRockReasonLeastPlayers = "You need more players before you can rock the vote!"

locale.helpscreenTitle = "HELP SCREEN"
locale.helpscreenHelpKey = "Press F2 at any time to close/view this screen again."

locale.helpscreenCurrentAbility = "<<< Your current ability (Use C to change it)"

locale.helpscreenNumOfEggs = "Your number of eggs. >>>"
locale.helpscreenThrowEgg = "Throw eggs at players to disorient them using rmb."
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


locale.mutatorsShouldStartAMutator = "Should we start a mutator? Let's roll!"
locale.mutatorsLetsMutatePrefix = "We rolled "
locale.mutatorsLetsMutateAnd = " and "
locale.mutatorsLetsMutateSuffix = "! Let's start us a mutator!"
locale.mutatorsNoMutatePrefix = "We rolled "
locale.mutatorsNoMutateAnd = " and "
locale.mutatorsNoMutateSuffix = "! Sorry chap! no mutator this round."

locale.mutatorsHasBegunPrefix = "The "
locale.mutatorsHasBegunSuffix = " mutator has begun!"
locale.mutatorsIsFlamerPrefix = ""
locale.mutatorsIsFlamerSuffix = " is the Flamer! Go give him a peepee touch!"

locale.abilityYourNewPrefix = "Your new ability is "
locale.abilityYourNewSuffix = "!"

lang_data[ LanguageCode ]  = locale