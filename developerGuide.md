dkurpg는 학과를 선택하고 몬스터를 사냥하며 학점을 모아 졸업을 목표로 하는 게임입니다.
이 가이드에서는 dkurpg를 어떻게 변형하거나 발전시킬 수 있는지에 대해 설명합니다.

## 목차
1. [ 🌏 개발 환경 ](#-개발-환경) 
2. [ 📁 파일 구성 ](#-파일-구성)
3. [ 📋 프로그램 구조](#-프로그램-구조)
4. [ 📄 코드 작성 가이드](#-코드-작성-가이드)
    - [코딩 스타일](#코딩-스타일)
    - [함수 기능(스크립트) 설명](#함수-기능스크립트-설명)
    - [게임 밸런스 및 이미지 변경 방법](#게임-밸런스-및-이미지-변경-방법)
    - [코드 외 개선 방법](#코드-외-개선-방법)
## 🌏 개발 환경
프로젝트 dkurpg의 경우 오픈소스 게임 엔진 중 하나인 4.4.1 버전의 **Godot Engine**을 바탕으로 스크립트는 **GDScript**, 데이터베이스는 **SQLite**를 사용합니다.    

고도 엔진(Godot Engine)의 경우 [공식 사이트](https://godotengine.org/)를 통해 설치 가능합니다. 깃허브에 올라와있는 dkurpg 프로젝트를 ZIP으로 다운받아 압축을 풀거나 본인의 레지스토리로 folk & pull 을 통해 로컬 저장소로 이동한 후 설치한 고도엔진에서 프로젝트 불러오기를 통해 project.godot 파일을 불러오면 파일을 편집 가능합니다.    

데이터베이스인 SQLite를 연동하기 위해서는 godot 공식 플러그인인 godot-sqlite가 addons/godot-sqlite 디렉토리의 GDExtension 플러그인이 있는지 확인해야합니다. SQLite로 생성되는 데이터베이스 파일은 db 파일로 저장되는데 이를 GUI를 이용해 확인하고 편집하고 싶다면 [SQLite Studio](https://www.sqlitestudio.pl/)등의 프로그램을 사용할 수도 있습니다.


## 📁 파일 구성
메인 폴더에는 위에서 설명한 데이터베이스 저장소인 db파일과 project.godot 파일, md 파일 등이 있으며, 하위 폴더로는 총 5가지로 구성되어있습니다.   
앞서 설명한 것처럼 플러그인 godot-sqlite을 담고있는 addons 폴더, 스크립트들을 모아놓은 scripts 폴더, 프로젝트에서 사용하는 이미지들을 모아놓은 sprites 폴더, md 파일에서 사용할 이미지들을 모아놓은 md_images 폴더, 고도엔진에서 사용하는 프로그램 기본 단위인 씬을 모아놓은 tscn 폴더가 있습니다.

## 📋 프로그램 구조
프로그램 구조를 글로 설명한 뒤에 이해하기 쉽도록 그림을 마지막에 보여드리겠습니다.  
  
파일 구성에서 잠깐 언급했다싶이 고도엔진에서 프로그램의 기본단위는 씬으로 레벨, 캐릭터, 메뉴, UI 등 모든 게임 요소를 포함하고 관리합니다.  
기본으로 프로젝트를 실행하게 된다면 메인씬으로 설정해놓은 씬이 실행되게 되는데 dkurpg에서는 메인씬의 이름을 Main으로 설정하고 있습니다. Main 씬에 처음 들어가게되면 로그인이 안되어 있다면 로그인 씬으로 이동하게 됩니다. 로그인 씬에서는 회원가입, 로그인을 통해 character_select 씬으로 이동하게 되고 처음 캐릭터가 생성되어있지 않다면 create_character 씬으로 이동후 캐릭터 생성을 한뒤 캐릭터를 선택하면 다시 Main 씬으로 이동하게 됩니다.  
로그인이 안되어 있을 때와 달리 로그인이 되어있다면 World_Scene과 플레이어 씬, 포탈 씬등을 띄워 게임 맵을 보여줍니다. 그리고 플레이어의 행위에 따라 스테이지 씬으로 이동하여 플레이어 씬과 몬스터 씬을 띄워  사냥터를 보여주기도 하고, 아이템 뽑기 씬을 띄워 아이템을 뽑거나 보유 아이템을 보는 등 여러 씬으로 이동이 가능합니다. 이를 그림으로 나타내면 다음과 같습니다.
![developGuide](/image/developGuide0.png)   
## 📄 코드 작성 가이드

## 코딩 스타일
 대표적인 예
- 들여쓰기 `space`를 사용하지 않고 `Tab `을 사용합니다.
- 변수 이름은 snake_case 스타일을 따르며, 단어 사이를 언더스코어(_)로 구분합니다.  

```
@onready var hp_label = $Panel/HPLabel
@onready var atk_label = $Panel/ATKLabel
@onready var def_label = $Panel/DEFLabel
@onready var int_label = $Panel/INTLabel
@onready var mov_label = $Panel/MOVLabel
@onready var skill_cooldown_label = $Panel/SkillCooldownLabel
```
- 함수와 함수 사이에 한 줄이상의 공백 줄을 사용합니다. 

```
func _process(delta):
	if skill_timer > 0:
		skill_timer = max(0, skill_timer - delta)
		skill_cooldown_label.text = str("쿨타임 : %.1f" % skill_timer)
	else:
		skill_cooldown_label.text = "Ready!"


func use_skill():
	if skill_timer == 0:
		# 스킬 사용 로직
		skill_timer = skill_cooldown 

```
이외에 더 자세한 코딩 스타일 가이드는 [GDScript 공식문서](https://docs.godotengine.org/ko/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html)를 참고하길 바랍니다.


## 함수 기능(스크립트) 설명
프로그램 구조에서는 씬에 대해 살펴보았습니다. 고도엔진에서는 씬 안에 노드들로 구성되어있고 노드에는 스크립트를 붙일 수 있습니다. 스크립트는 해당 노드가 작동하는 방식을 결정한다고 보면 되는데 이 파트에서는 개발자 분들이 각 스크립트들의 함수가 어떤 역할을 하는지를 확인하고 수정하고자 하는 부분을 명확히 알 수 있도록 스크립트 내 함수들을 설명하도록 하겠습니다.  스크립트 전체가 하나의 역할을 수행하거나 부가적인 설명이 필요없을만한 스크립트들은 함수를 굳이 나누지않고 전체적으로 설명하겠습니다.
  
스크립트를 보기전에 고도엔진에서 기본으로 쓰는 함수들을 설명하자면 _ready, _input,_process 등이 있습니다 _ready는 씬이 시작될때 기본으로 실행되는 함수이고 _input은 키 입력 이벤트를 처리하는 함수,_process는 매 프레임마다 자동으로 호출되는 함수입니다.    

이제 구체적으로 스크립트를 설명해보겠습니다. 메인씬을 보자면 _ready 에서 로그인 상태에 따라 패널을 숨기거나 게임을 시작하는 것을 나타내고 playInit은 맵, 플레이어, 여러 개의 포탈을 동적으로 생성하고 배치하며 진행도(HUD.progress)에 따라 보스 포탈의 잠금 여부와 라벨을 설정합니다. HUD 변수에 대해서는 메인 스크립트 다음에 설명하겠습니다. _input는 입력 받은 J,K,L에 따라 다양한 창을 띄우거나 숨기는 함수입니다. J,K,L을 입력한 것인지 아는 방법은 입력 맵을 미리 설정해놓으면 되는데 [추후 파트](#코드-외-개선-방법)에서 설명하겠습니다. _on_login_success은 로그인 성공시 실행되는 함수로 캐릭터 선택 씬으로 전환하고 HUD의 id를 설정해줍니다. show_login_scene은 로그인 씬을 인스턴스화해서 추가, 로그인 성공 시그널을 연결하고, HUD를 숨기는 역할을 합니다. item_check는 데이터베이스에서 현재 캐릭터의 장비 정보를 조회하여 배열로 반환합니다. 마지막 playGame은 게임 플레이를 시작하는 함수로 비로그인시 숨겨두었던 패널, HUD 등을 보여주고 playInit 함수를 실행합니다. 
 
HUD 씬은 프로젝트 전체에서 사용되는 변수나 함수등을 모아놓은 씬입니다. 프로젝트 설정에서 Globals에 씬을 저장해놓으면 프로젝트 어느 곳에서나 접근이 가능합니다. 실행 순서도 메인씬이 실행되기전에 가장먼저 실행됩니다.

character_select 스크립트는  데이터베이스에서 생성되어있는 캐릭터 정보를 불러와 화면에 출력하는 역할을 합니다. character_select 씬에는 세 개의 노드(CharBox)로 구성되어있는데  각 노드에 붙어있는 스크립트들을 보면 캐릭터 정보를 보여주는 함수 show_character, 생성되어있는 캐릭터가 없다면 + 버튼을 보여주고 + 버튼을 누르면 캐릭터 생성 씬으로 넘어가는 show_plus_button,_on_plus_button_pressed, 캐릭터 삭제할 수 있는 _on_delete_button_pressed, 캐릭터 선택 후 메인 씬으로 돌아가는 _on_select_button_pressed까지로 구성되어있습니다.  
\+ 버튼을 눌러 넘어가는 create_character에서는 직업을 고르고 이름을 골라 캐릭터를 생성한 뒤 다시 캐릭터 선택창으로 돌아가는 것을 구현하고 있습니다.

다음으로 Player 스크립트를 보겠습니다. _ready 는 캐릭터 정보를 데이터베이스에서 불러오고, 아이템 효과를 적용하며, 초기 상태와 애니메이션을 설정합니다. 그 과정에서 load_stats_from_db
와 plus_item_stat를 사용하는데 각각 데이터베이스에서 캐릭터의 능력치와 직업 정보를 불러오고, 각 장비의 추가 능력치를 데이터베이스에서 불러와 HUD에 반영하는 것을 구현한 함수들입니다. 그 다음 _process와 _physics_process가 있는데 _physics_process은 물리 프레임마자 호출되며 이동 입력을 받아 캐릭터를 이동시키고, 이동 애니메이션 처리, 대시 상태일때 속도 증가등의 역할을 합니다. _process는 스킬 및 공격 입력을 처리하고 직업별 스킬 발동 조건을 판정합니다. shoot은 입력 방향에 따라 원거리 공격을 생성해 발사시켜주는 함수이며 near_attack는 근접 공격 로직을 담당하는 함수입니다.take_damage는 캐릭터가 데미지를 입게하는 로직, die는 캐릭터가 사망했을때 사망신호를 내보내고 캐릭터를 씬에서 제거하는 역할, add_item은 아이템 획득시 그것을 HUD에 반영하는 역할을 합니다. start_dash는 대시(순간 가속)를 시작하며 타이머 시작, _on_dash_timer_timeout에서 대시 지속시간이 끝나면 대시 상태를 해제하는 역할을 합니다. 마지막 _input과 _on_animated_sprite_2d_animation_finished은 모션을 보여주기 위해 사용되었습니다.

Portal 스크립트는 플레이어가 포탈 범위에 들어가서 방향키 위키를 누르면 스테이지 이동을 하게하는 로직을 담당하고 있고 job_description은 데이터베이스에 저장되어있는 직업 설명 출력,item_view는 플레이어가 가지고 있는 장비를 화면에 보여주는 역할, game_help는 게임에 목표, 게임 설명등을 출력해주는 역할을 합니다.

random_item에서는 장비를 뽑는 로직을 구현하고 있는데 미니게임 버튼을 클릭해 미니게임을 성공시 true 값을 반환하여 높은 수준의 장비를 뽑을 확률이 올라가는 로직을 담당하고 있습니다.

여러 Monster 관련 스크립트들은 player 와 비슷한데 다른 점은 이동 로직이 플레이어는 방향키였던 반면 몬스터는 주변 플레이어를 인식하고 플레이어 방향으로 이동합니다. 또 각 몬스터의 특징에 따라 스킬 또는 근접 공격을 사용해 플레이어를 공격합니다.



## 게임 밸런스 및 이미지 변경 방법
게임을 생각하면 눈에 보이는 것과 밸런스 문제는 뗄래야 뗄 수 없는 문제입니다. 그렇기 때문에 이 두 부분을 따로 떼어 변경할 수 있는 방법을 안내하기 위해 이 파트를 만들었습니다.

### 밸런스 조절  
먼저 밸런스 부분입니다. 현재 dkurpg는 밸런스라고 할만한 부분이 플레이어의 스탯, 몬스터의 스탯, 아이템 스텟,추가로 아이템 획득 확률 정도가 있습니다. 현재 몬스터의 스탯은 플레이어가 획득한 학점(progress)에 공격력과 데미지에 차이를 두게 됩니다. 몬스터들은 각 특성에 맞게 근접공격을 하거나 스킬을 사용하는데 근접공격에 경우 monster 스크립트에 스킬에 경우, 스킬 스크립트(aura,lighting_effect,fireball_monster 등)에 스탯을 조절하는 로직이 있습니다.
- 스킬 스크립트`@export var damage: int = HUD.progress / 4 + 1`
- 몬스터 스크립트 `var damage_number = HUD.progress/5 +1`    

그리고  몬스터의 체력을 담당하는 부분도 몬스터 스크립트에서 학점에 비례해 증가하고 있습니다.
- 몬스터 스크립트 `var health = HUD.progress * 1.5 +5`

참고로 아이템 획득 확률도 몬스터 스크립트에서 조절 가능합니다
- 몬스터 스크립트`var drop_chance = 0.5 #드롭확률`

플레이어의 밸런스 부분은 크게 스텟과 스킬 계수로 나누어집니다. 스킬 계수 관련된 부분은 player 스크립트에 존재하며 SW 직업과 체육학과 직업의 스킬 계수는 near_attack 함수에 다음 부분에서 조정가능합니다.
```
func near_attack(direction: Vector2):
	var damage = (HUD.ATK+HUD.ATKItem) + (HUD.MOV + HUD.MOVItem) * 0.25
	if is_dash_attack:
		damage *=2
		is_dash_attack = false
		#이미지 해제
	if is_reinforce:
		$attackeparent/nearAttackLv1/Sprite2D.texture = attack_texture_lv1	
		$attackeparent/nearAttackLv1.damage = damage*1.5
		$attackeparent/nearAttackLv1.activate()
		print(1)
	elif is_reinforce_lv2:
		$attackeparent/nearAttackLv2/Sprite2D.texture = attack_texture_lv2
		$attackeparent/nearAttackLv2.damage = damage*2
		$attackeparent/nearAttackLv2.activate()		
		print(2)
	else:
		$attackeparent/nearAttack/Sprite2D.texture = attack_texture	
		$attackeparent/nearAttack.damage = damage
		$attackeparent/nearAttack.activate()
```

스텟 조절은 stage 스크립트에서 조절 가능합니다.

```
#스텟 늘리는 양 (조절가능)
	tmp = monsters_defeated/2
	db.query("UPDATE character SET ATK = Atk + %d, Progress = %d, HP=%d,ItemCount = %d WHERE character_name = '%s'" % [tmp, HUD.progress,HUD.progress/2,HUD.itemCount,HUD.char_name])

```
마지막 밸런스 부분으로는 아이템의 스텟 조정은 앞선 부분들과 달리 코드를 수정할 필요는 없습니다. 방법으로는 데이터베이스에 아이템 테이블에 아이템 정보가 저장되어있는데 그곳에 아이템의 스텟이 저장되어있어 그 부분을 바꾸어주면 아이템 스텟이 변경되게 됩니다.

### 이미지 변경
게임에서 사용한 이미지들에는 맵 이미지, 스킬 이미지, 아이템 이미지, 플레이어 이미지, 몬스터 이미지 등이 있습니다. 이미지는 프레임 단위로 움직이는 모습을 나타내는 이미지와 정적인 이미지가 있는데 정적인 이미지를 변경하는 방법은 간단합니다. 가장 간단한 방법은 바꾸고 싶은 이미지를 대체하려는 이미지 이름과 같게 바꾼 후 sprites 폴더 내 대체하려는 이미지 위치에 두면 됩니다. 이미 코드 상에서 이미지의 이름을 기준으로 이미지를 불러오고 있기때문에 이미지 이름을 동일시 하면 이미지 변경이 가능합니다. 만약 이미지 이름을 바꾸고 싶다면 이미지를 대체한 후 그 이미지를 불러오고 있는 스크립트에서 이미지 이름을 변경해주면 됩니다.  만약 동적인 이미지를 변경하고 싶으면 애니메이트스프라이트를 변경하면 됩니다. 대체하고자하는 이미지를 불러오는 씬으로 가서 animatedSprite2d 노드를 클릭하면 에디터 하단에 애니메이터 편집창이 나옵니다. 거기에다가 바꾸고 싶은 이미지를 넣으면 이미지 변경이 가능합니다.

## 코드 외 개선 방법
고도 엔진 에디터를 들어가면 각 씬 안에 노드들이 구성되어있고 노드들의 인스펙터 창을 확인 할 수 있습니다. 인스펙터 창에서는 자주 사용하는 일부 기능들을 손쉽게 조작 가능하도록 만들어져있어 직관적이고 비개발자도 쉽게 변경가능합니다. 그 예로 각 노드들의 사이즈, 위치 ,Layer설정 등을 인스펙터 창으로 조작 가능합니다. 또 코드에서 @export 를 붙여 생성한 변수도 인스펙터 창에서 조작 가능합니다. 물론 인스펙터를 사용하지 않고 코드로만 작업도 가능하며 하나의 노드마다 수동으로 조작을 해야하기때문에 반복되는 작업을 할 때는 비효율적일 수 있어 반복해야하는 작업은 코드로 작성을 하는것이 더 좋을 수 있습니다.    

인스펙터와 같이 코드에서도 구현은 가능하지만 손쉽게 설정가능한 것이 '프로젝트 설정' 입니다. 에디터에서 프로젝트 - 프로젝트 설정 을 들어가면 여러 설정들이 나오는데 키 입력을 처리하는 방식이나 프로젝트 내 전역에서 사용할 수 있는 변수 등을 이곳에서 설정 가능합니다.
 


