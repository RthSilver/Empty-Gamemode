//----------------------------------------------------------
//
//  INFRASTRUCTURE=> GRAND LARCENY 1.0
//  A empty gamemode for SA-MP 0.3.7
//  Gamemode creator Rth. Silver_
//
//----------------------------------------------------------

#include <a_samp>
#include <extra/a_mysql>
#include <extra/Pawn.CMD>
#include <extra/sscanf2>
#include <extra/foreach>
#include <extra/streamer>
#include <extra/easyDialog>
#include <extra/weapon-config>

#define function:%0(%1) forward %0(%1); public %0(%1)

#define KomutBilgisi(%0,%1) SendClientMessageEx(%0, -1, "{e3e4a9}KULLANIM |{FFFFFF} "%1)
#define SunucuMesaji(%0,%1) SendClientMessageEx(%0, -1, "{A9C4E4}SUNUCU |{FFFFFF} "%1)
#define HataMesaji(%0,%1) SendClientMessageEx(%0, -1, "{d90f00}HATA |{FFFFFF} "%1)

//------------------------------------------------------------------//
#define GM_TYPE    						"Mixed"
#define DEVELOPER_ 						"Rth. Silver_"
#define GAMEMODE_NAME                   "Empty Gamemode - |||2022|||"
#define GAMEMODE_TEXT                   "Mixed v1.0.0"
#define GAMEMODE_WEB                    "na-mevcut"
#define GAMEMODE_LANG                   "TRTürkçeTürkiyeTurkishTurk"
#define GAMEMODE_MAP					"anywhere"
#define DEFAULT_SKIN					(26)
//------------------------------------------------------------------//
#define REGISTER_METHOD 				(1)
#define LOGIN_METHOD 					(2)
#define AFTER_LOGIN_METHOD 				(3)

#define ROOM_EMPTY						(1)
#define ROOM_FREEROAM					(1)
#define ROOM_DERBY						(2)

#define READING_RULE_TIME 				(5)//sec
//------------------------------------------------------------------//
new MySQL: conn;
//******TEXTDRAWS******//
new PlayerText:SureliKararti[MAX_PLAYERS];
new PlayerText:KayitGiris[13][MAX_PLAYERS];
//******ALL TIMERS******//
new GirisEfektSondur[MAX_PLAYERS];
new KayitGirisEkrani[MAX_PLAYERS];
new KurallariOku[MAX_PLAYERS];
//------------------------------------------------------------------//

enum pDatas
{
	pSQLID,
	pAdminLevel,
	pRegisterOrLogin,
	pPassword[30],
	pCash,
	pFirstLogin,
	pRuleReading,
	pRoom,
	bool:pSpawnProtect
};
new playerData[MAX_PLAYERS][pDatas];

new Float:SPAWN_POSITIONS[][] =
{
	{2015.2090,1246.5328,10.8203,311.1254},
	{2081.0779,1441.5073,10.8203,138.6567},
	{2014.1202,1545.2081,11.2288,270.1642},
	{2150.3025,1687.6998,10.8203,116.7777}
};

main()
{
	print("\n----------------------------------");
	printf(" %s Gamemode by %s", GM_TYPE, DEVELOPER_);
	print("----------------------------------\n");
}

//-------- STOCK'S --------

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static args, str[144];

	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return true;
}

stock DeniedAuthority(playerid)
{
	SendClientMessage(playerid, 0xd90f00FF, "HATA | Bu komuta erişim izniniz bulunmuyor.");
	return true;
}

stock GetPlayerSpeed(playerid)
{
	new Float:xx, Float:yy, Float:zz, Float:pSpeed;
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid),xx,yy,zz);
	}
	else
	{
		GetPlayerVelocity(playerid,xx,yy,zz);
	}
	pSpeed = floatsqroot((xx * xx) + (yy * yy) + (zz * zz));
	return floatround((pSpeed * 160.12));
}

stock GetPlayerNameEx(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock GetUnixTimeStampValue()
{
	new unixvalue[11], year, month, day, hour, minute, second;
	getdate(year, month, day); gettime(hour, minute, second);
	//#pragma unused second
	format(unixvalue, sizeof(unixvalue), "%02d/%02d/%d - %02d:%02d", day, month, year, hour, minute);
	return unixvalue;
}

stock ConvertUnixTimeStamp(zamanlayici, _format = 0)
{
	new year=1970, day=0, month=0, hour=0, mins=0, sec=0;

	new days_of_month[12] = { 31,28,31,30,31,30,31,31,30,31,30,31 };
	new names_of_month[12][10] = {"Ocak","Subat","Mart","Nisan","Mayis","Haziran","Temmuz","Agustos","Eylul","Ekim","Kasim","Aralik"};
	new returnstring[36];

	while(zamanlayici>31622400){
		zamanlayici -= 31536000;
		if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) ) zamanlayici -= 86400;
		year++;
	}

	if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )
		days_of_month[1] = 29;
	else
		days_of_month[1] = 28;


	while(zamanlayici>86400){
		zamanlayici -= 86400, day++;
		if(day==days_of_month[month]) day=0, month++;
	}

	while(zamanlayici>60){
		zamanlayici -= 60, mins++;
		if( mins == 60) mins=0, hour++;
	}

	sec=zamanlayici;
	new zamanfix;
	zamanfix = hour + 3;
	if(zamanfix >= 24)
	{
		zamanfix = 0;
	}
	switch( _format ){
		case 1: format(returnstring, 31, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, zamanfix, mins, sec);
		case 2: format(returnstring, 31, "%s %02d, %d, %02d:%02d:%02d", names_of_month[month],day+1,year, zamanfix, mins, sec);
		case 3: format(returnstring, 31, "%d %c%c%c %d, %02d:%02d", day+1,names_of_month[month][0],names_of_month[month][1],names_of_month[month][2], year,zamanfix,mins);
		case 4: format(returnstring, 31, "%02d.%02d.%d", day+1, month+1, year);
		case 5: format(returnstring, 31, "%02d/%02d/%d - %02d:%02d", day+1, month+1, year, zamanfix, mins);
		default: format(returnstring, 31, "%02d.%02d.%d - %02d:%02d:%02d", day+1, month+1, year, zamanfix, mins, sec);
	}

	return returnstring;
}

stock HazirKayitGirisMenusu(playerid, dialog_, string[] = "")
{
	new datastring[128 * 5];
	if(strlen(string) >= 1)
	{
		format(datastring, sizeof(datastring), "{CC0000}ERR: %s{FFFFFF}\n\n", string);
	}

	switch(dialog_)
	{
		case REGISTER_METHOD: 
		{
			if(playerData[playerid][pRuleReading] >= 1 && playerData[playerid][pRuleReading] < READING_RULE_TIME) return true;
			format(datastring, sizeof(datastring), "%s{FFFFFF}Merhaba {1AFF1A}%s{FFFFFF}, Turkish Texas'a hoş geldiniz!\n\nBu hesap kayıtlı değil, oynamak için bir şifre oluşturun.", datastring, GetPlayerNameEx(playerid));
			Dialog_Show(playerid, KAYIT_MENUSU, DIALOG_STYLE_INPUT, "{1EC684}>{13DE8E}>{06FE9C}>{FFFFFF} Kayıt Ekranı", datastring, "Onayla", "Iptal");
		}
		case LOGIN_METHOD: 
		{
			if(strlen(playerData[playerid][pPassword]) < 1)
			{
				format(datastring, sizeof(datastring), "%s{FFFFFF}Merhaba {1AFF1A}%s{FFFFFF}, Turkish Texas'a hoş geldin!\n\nBu hesap kayıtlı, hesapta oynamak için hemen giriş yapabilirsin:", datastring, GetPlayerNameEx(playerid));
				Dialog_Show(playerid, GIRIS_MENUSU, DIALOG_STYLE_PASSWORD, "{1EC684}>{13DE8E}>{06FE9C}>{FFFFFF} Giriş Ekranı", datastring, "Onayla", "Iptal");
			}
			else
			{
				LoginMethodControl(playerid, playerData[playerid][pPassword]);
			}
		}
		default: Kick(playerid);
	}
	return true;
}

stock ShowServerRules(playerid)
{
	new waitingtime[32], laststring[128], dialogstring[1024 * 3], header_[128];
	if(playerData[playerid][pRuleReading] > 0)
	{
		format(waitingtime, sizeof(waitingtime), "BEKLE {FF0000}(%d)", playerData[playerid][pRuleReading]);
	}
	else if(playerData[playerid][pRuleReading] <= 0)
	{
		format(waitingtime, sizeof(waitingtime), "{47B1FF}OK");
		if(playerData[playerid][pRuleReading] == 0)
		{	
			format(laststring, sizeof(laststring), "\n{DE0D0D}** Kayıt işlemine devam edebilirsiniz.");
		}
		else if(playerData[playerid][pRuleReading] == -1)
		{
			format(laststring, sizeof(laststring), "\n{7C7C7C}** Kuralları baştan sona okudunuz ve tümünü kabul ettiniz.");
		}
	}
	format(dialogstring, sizeof(dialogstring), "%s\n{FFFFFF}1.) Üstünlük sağlayan modlar kullanmak YASAKTIR. (Hileler, üçüncü parti yazılım ile eklenti eklemek vb.).\n", dialogstring);
	format(dialogstring, sizeof(dialogstring), "%s2.) Herhangi bir ceza aldığınızda, ceza süresini beklemeden yeni hesap açmak YASAKTIR.\n", dialogstring);
	format(dialogstring, sizeof(dialogstring), "%s3.) Herkese açık kanallarda hakaret etmek ve arka arkaya hızlı bir şekilde yazmak YASAKTIR.\n", dialogstring);
	if(strlen(laststring) > 0)
	{
		format(dialogstring, sizeof(dialogstring), "%s%s", dialogstring, laststring);
	}
	format(header_, sizeof(header_), "{8044A5}>{902ACE}>{BA47FF}>{FFFFFF} Zorunlu Tutulan Sunucu Kuralları %s", (playerData[playerid][pRuleReading] <= 0) ? ("{6CFE44}[OKUNDU]") : ("{9D9D9D}[OKUNMADI]"));
	Dialog_Show(playerid, SUNUCU_KURALLARI, DIALOG_STYLE_MSGBOX, header_, dialogstring, waitingtime, "");
	return true;
}

stock GivePlayerToFreeroamWeapons(playerid, number)
{
	ResetPlayerWeapons(playerid);
	switch(number)
	{
		case 0:
		{
			GivePlayerWeapon(playerid, WEAPON_DEAGLE, 9999);
			GivePlayerWeapon(playerid, WEAPON_M4, 9999);
			GivePlayerWeapon(playerid, WEAPON_RIFLE, 9999);
			GivePlayerWeapon(playerid, WEAPON_SPRAYCAN, 9999);
			GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 9999);
			GivePlayerWeapon(playerid, WEAPON_SATCHEL, 10);
			GivePlayerWeapon(playerid, WEAPON_MOLTOV, 5);

		}
		case 1:
		{
			GivePlayerWeapon(playerid, WEAPON_DEAGLE, 9999);
			GivePlayerWeapon(playerid, WEAPON_AK47, 9999);
			GivePlayerWeapon(playerid, WEAPON_SNIPER, 9999);
			GivePlayerWeapon(playerid, WEAPON_FIREEXTINGUISHER, 9999);
			GivePlayerWeapon(playerid, WEAPON_SAWEDOFF, 9999);
			GivePlayerWeapon(playerid, WEAPON_SATCHEL, 10);
			GivePlayerWeapon(playerid, WEAPON_GRENADE, 5);
		}
	}
	return true;
}

//-------- FUNCTION'S --------

function:LoginMethodControl(playerid, inputtext[])
{
	if(strlen(inputtext) < 6) return HazirKayitGirisMenusu(playerid, LOGIN_METHOD, "Geçersiz şifre!");
	
	new query[128], Cache:getQuery;
	mysql_format(conn, query, sizeof(query), "SELECT * FROM `oyuncular` WHERE `Nick` LIKE '%e' AND `Password` LIKE sha1('%e') LIMIT 1", GetPlayerNameEx(playerid), inputtext);
	getQuery = mysql_query(conn, query);

	if(cache_num_rows())
	{
		playerData[playerid][pRegisterOrLogin] = AFTER_LOGIN_METHOD;
		playerData[playerid][pRoom] = ROOM_FREEROAM;

		for(new i ; i < sizeof(KayitGiris); i ++)
		{
			PlayerTextDrawHide(playerid, KayitGiris[i][playerid]);
		}
		TogglePlayerSpectating(playerid, false);
		SpawnPlayer(playerid);
		SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
		SetPlayerFacingAngle(playerid, 270);
		CancelSelectTextDraw(playerid);
		SetPVarInt(playerid, "EffectValue", 1);
		Giris_TextdrawSondur(playerid);
	}
	else{
		HazirKayitGirisMenusu(playerid, LOGIN_METHOD, "Yanlış şifre!");
	}
	cache_delete(getQuery);
	return true;
}

function:ReplacedRandomFunc(randvalue)
{
	return random(randvalue + 1);
}

function:RconExitTimer()
{
	return SendRconCommand("exit");
}

function:LoadGamemodeSettings()
{
    mysql_log(ERROR | WARNING);
    conn = mysql_connect("localhost", "root", "aDmin133729", "derby");
    if(mysql_errno(conn)) return printf("--------------------------------------\n\n•[!mySQL]: Bilesen baglantisi basarisiz, yeniden deneyin."), SetTimer("RconExitTimer", 1000, true);

    mysql_set_charset("latin5", conn);
    printf("--------------------------------------\n\n[mySQL]: Bilesen baglantisi basariyla saglandi.");

	//------------------------------------------------//
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(2);
	SetWorldTime(12);
	SetObjectsDefaultCameraCol(true);
	ManualVehicleEngineAndLights();
	//------------------------------------------------//
	new stringsize[128];
	format(stringsize, sizeof(stringsize), "rcon_password Tm29H04cY"); SendRconCommand(stringsize);
	format(stringsize, sizeof(stringsize), "hostname %s", GAMEMODE_NAME); SendRconCommand(stringsize);
	format(stringsize, sizeof(stringsize), "%s", GAMEMODE_TEXT); SetGameModeText(stringsize);
	format(stringsize, sizeof(stringsize), "weburl %s", GAMEMODE_WEB); SendRconCommand(stringsize);
	format(stringsize, sizeof(stringsize), "language %s", GAMEMODE_LANG); SendRconCommand(stringsize);
	format(stringsize, sizeof(stringsize), "mapname %s", GAMEMODE_MAP); SendRconCommand(stringsize);

	return true;
}

function:LoadPlayerTextDraws(playerid)
{
	SureliKararti[playerid] = CreatePlayerTextDraw(playerid, 318.000000, 0.000000, "_");
	PlayerTextDrawFont(playerid, SureliKararti[playerid], 1);
	PlayerTextDrawLetterSize(playerid, SureliKararti[playerid], 0.600000, 50.000000);
	PlayerTextDrawTextSize(playerid, SureliKararti[playerid], 298.500000, 650.000000);
	PlayerTextDrawSetOutline(playerid, SureliKararti[playerid], 1);
	PlayerTextDrawSetShadow(playerid, SureliKararti[playerid], 0);
	PlayerTextDrawAlignment(playerid, SureliKararti[playerid], 2);
	PlayerTextDrawColor(playerid, SureliKararti[playerid], 255);
	PlayerTextDrawBackgroundColor(playerid, SureliKararti[playerid], 255);
	PlayerTextDrawBoxColor(playerid, SureliKararti[playerid], 255);
	PlayerTextDrawUseBox(playerid, SureliKararti[playerid], 1);
	PlayerTextDrawSetProportional(playerid, SureliKararti[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, SureliKararti[playerid], 0);
	PlayerTextDrawShow(playerid, SureliKararti[playerid]);

	KayitGiris[0][playerid] = CreatePlayerTextDraw(playerid, 123.000000, 106.000000, "_");
	PlayerTextDrawFont(playerid, KayitGiris[0][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[0][playerid], 0.579165, 28.099998);
	PlayerTextDrawTextSize(playerid, KayitGiris[0][playerid], 298.500000, 180.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[0][playerid], 1);
	PlayerTextDrawSetShadow(playerid, KayitGiris[0][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[0][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[0][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[0][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[0][playerid], 336860415);
	PlayerTextDrawUseBox(playerid, KayitGiris[0][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[0][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[0][playerid], 0);

	KayitGiris[1][playerid] = CreatePlayerTextDraw(playerid, 126.000000, 123.000000, "Empty Gamemode");
	PlayerTextDrawFont(playerid, KayitGiris[1][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[1][playerid], 0.274998, 1.299998);
	PlayerTextDrawTextSize(playerid, KayitGiris[1][playerid], 400.000000, 249.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[1][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[1][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[1][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[1][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[1][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[1][playerid], 50);
	PlayerTextDrawUseBox(playerid, KayitGiris[1][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[1][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[1][playerid], 0);

	KayitGiris[2][playerid] = CreatePlayerTextDraw(playerid, 123.000000, 173.000000, "~l~Bu kullanici adina ait hesap ~r~~h~yok~l~.");
	PlayerTextDrawFont(playerid, KayitGiris[2][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[2][playerid], 0.170833, 0.899999);
	PlayerTextDrawTextSize(playerid, KayitGiris[2][playerid], 400.000000, 180.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[2][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[2][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[2][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[2][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[2][playerid], 100);
	PlayerTextDrawBoxColor(playerid, KayitGiris[2][playerid], -1061109660);
	PlayerTextDrawUseBox(playerid, KayitGiris[2][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[2][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[2][playerid], 0);

	KayitGiris[3][playerid] = CreatePlayerTextDraw(playerid, 68.000000, 215.000000, "_");
	PlayerTextDrawFont(playerid, KayitGiris[3][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[3][playerid], -0.099999, 1.650002);
	PlayerTextDrawTextSize(playerid, KayitGiris[3][playerid], 263.500000, 16.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[3][playerid], 1);
	PlayerTextDrawSetShadow(playerid, KayitGiris[3][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[3][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[3][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[3][playerid], -741092353);
	PlayerTextDrawBoxColor(playerid, KayitGiris[3][playerid], 1296911871);
	PlayerTextDrawUseBox(playerid, KayitGiris[3][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[3][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[3][playerid], 0);

	KayitGiris[4][playerid] = CreatePlayerTextDraw(playerid, 61.000000, 214.000000, "HUD:radar_gangy");
	PlayerTextDrawFont(playerid, KayitGiris[4][playerid], 4);
	PlayerTextDrawLetterSize(playerid, KayitGiris[4][playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, KayitGiris[4][playerid], 13.500000, 17.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[4][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[4][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[4][playerid], 1);
	PlayerTextDrawColor(playerid, KayitGiris[4][playerid], 1097458160);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[4][playerid], 0);
	PlayerTextDrawBoxColor(playerid, KayitGiris[4][playerid], 0);
	PlayerTextDrawUseBox(playerid, KayitGiris[4][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[4][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[4][playerid], 0);

	KayitGiris[5][playerid] = CreatePlayerTextDraw(playerid, 80.000000, 216.000000, "_");
	PlayerTextDrawFont(playerid, KayitGiris[5][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[5][playerid], 0.183330, 1.400002);
	PlayerTextDrawTextSize(playerid, KayitGiris[5][playerid], 185.000000, 104.500000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[5][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[5][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[5][playerid], 1);
	PlayerTextDrawColor(playerid, KayitGiris[5][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[5][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[5][playerid], 1296911849);
	PlayerTextDrawUseBox(playerid, KayitGiris[5][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[5][playerid], 0);

	KayitGiris[6][playerid] = CreatePlayerTextDraw(playerid, 81.000000, 218.000000, "Rth. Silver_");
	PlayerTextDrawFont(playerid, KayitGiris[6][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[6][playerid], 0.158333, 0.949998);
	PlayerTextDrawTextSize(playerid, KayitGiris[6][playerid], 186.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[6][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[6][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[6][playerid], 1);
	PlayerTextDrawColor(playerid, KayitGiris[6][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[6][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[6][playerid], 50);
	PlayerTextDrawUseBox(playerid, KayitGiris[6][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[6][playerid], 1);

	KayitGiris[7][playerid] = CreatePlayerTextDraw(playerid, 123.000000, 245.000000, "KAYIT OL");
	PlayerTextDrawFont(playerid, KayitGiris[7][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[7][playerid], 0.187500, 1.350003);
	PlayerTextDrawTextSize(playerid, KayitGiris[7][playerid], 10.000000, 128.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[7][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[7][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[7][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[7][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[7][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[7][playerid], 1433087944);
	PlayerTextDrawUseBox(playerid, KayitGiris[7][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[7][playerid], 1);

	KayitGiris[8][playerid] = CreatePlayerTextDraw(playerid, 123.000000, 263.000000, "OYUN KURALLARI");
	PlayerTextDrawFont(playerid, KayitGiris[8][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[8][playerid], 0.187500, 1.350003);
	PlayerTextDrawTextSize(playerid, KayitGiris[8][playerid], 10.000000, 128.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[8][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[8][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[8][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[8][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[8][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[8][playerid], 1296911716);
	PlayerTextDrawUseBox(playerid, KayitGiris[8][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[8][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[8][playerid], 1);

	KayitGiris[9][playerid] = CreatePlayerTextDraw(playerid, 126.000000, 144.000000, "V1.0");
	PlayerTextDrawFont(playerid, KayitGiris[9][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[9][playerid], 0.216665, 1.099997);
	PlayerTextDrawTextSize(playerid, KayitGiris[9][playerid], 400.000000, 249.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[9][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[9][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[9][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[9][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[9][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[9][playerid], 50);
	PlayerTextDrawUseBox(playerid, KayitGiris[9][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[9][playerid], 0);

	KayitGiris[10][playerid] = CreatePlayerTextDraw(playerid, 57.000000, 203.000000, "Sifre islemleri icin lutfen kullanici adinizin uzerine tiklayin.");
	PlayerTextDrawFont(playerid, KayitGiris[10][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[10][playerid], 0.095833, 0.850000);
	PlayerTextDrawTextSize(playerid, KayitGiris[10][playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[10][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[10][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[10][playerid], 1);
	PlayerTextDrawColor(playerid, KayitGiris[10][playerid], -204);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[10][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[10][playerid], 50);
	PlayerTextDrawUseBox(playerid, KayitGiris[10][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[10][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[10][playerid], 0);

	KayitGiris[11][playerid] = CreatePlayerTextDraw(playerid, 59.000000, 304.000000, "~r~>>~w~ Hos geldin!~n~~n~Her zevke uygun oyun modlari olusuturulmaya devam edilecektir. Eglenceye katilmak icin zaman kaybetme!");
	PlayerTextDrawFont(playerid, KayitGiris[11][playerid], 1);
	PlayerTextDrawLetterSize(playerid, KayitGiris[11][playerid], 0.141665, 0.949998);
	PlayerTextDrawTextSize(playerid, KayitGiris[11][playerid], 187.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[11][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[11][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[11][playerid], 1);
	PlayerTextDrawColor(playerid, KayitGiris[11][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[11][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[11][playerid], 50);
	PlayerTextDrawUseBox(playerid, KayitGiris[11][playerid], 0);
	PlayerTextDrawSetProportional(playerid, KayitGiris[11][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[11][playerid], 0);

	KayitGiris[12][playerid] = CreatePlayerTextDraw(playerid, 123.000000, 281.000000, "HESAP SIZIN MI?");
	PlayerTextDrawFont(playerid, KayitGiris[12][playerid], 2);
	PlayerTextDrawLetterSize(playerid, KayitGiris[12][playerid], 0.187500, 1.350003);
	PlayerTextDrawTextSize(playerid, KayitGiris[12][playerid], 10.000000, 128.000000);
	PlayerTextDrawSetOutline(playerid, KayitGiris[12][playerid], 0);
	PlayerTextDrawSetShadow(playerid, KayitGiris[12][playerid], 0);
	PlayerTextDrawAlignment(playerid, KayitGiris[12][playerid], 2);
	PlayerTextDrawColor(playerid, KayitGiris[12][playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, KayitGiris[12][playerid], 255);
	PlayerTextDrawBoxColor(playerid, KayitGiris[12][playerid], 1296911716);
	PlayerTextDrawUseBox(playerid, KayitGiris[12][playerid], 1);
	PlayerTextDrawSetProportional(playerid, KayitGiris[12][playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KayitGiris[12][playerid], 1);
	return true;
}

function:Giris_TextdrawSondur(playerid)
{
	if(GetPVarInt(playerid, "EffectValue") >= 1)
	{
		SetPVarInt(playerid, "EffectValue", GetPVarInt(playerid, "EffectValue") - 1);
		PlayerTextDrawHide(playerid, SureliKararti[playerid]);
		PlayerTextDrawColor(playerid, SureliKararti[playerid], GetPVarInt(playerid, "EffectValue"));
		PlayerTextDrawBackgroundColor(playerid, SureliKararti[playerid], GetPVarInt(playerid, "EffectValue"));
		PlayerTextDrawBoxColor(playerid, SureliKararti[playerid], GetPVarInt(playerid, "EffectValue"));
		PlayerTextDrawShow(playerid, SureliKararti[playerid]);

		//printf("%d", GetPVarInt(playerid, "EffectValue"));
		if(GetPVarInt(playerid, "EffectValue") <= 1)
		{
			PlayerTextDrawHide(playerid, SureliKararti[playerid]);
			KillTimer(GirisEfektSondur[playerid]);
		}
	}
	return true;
}

function:ApplyLoginEffect(playerid)
{
	GirisEfektSondur[playerid] = SetTimerEx("Giris_TextdrawSondur", 120, true, "i", playerid);
	KayitGirisEkrani[playerid] = SetTimerEx("RegisterLoginScreen", 1800, false, "i", playerid);
	return true;
}

function:GetFirstVariable(playerid)
{
	cache_get_value_name_int(0, "id", playerData[playerid][pSQLID]);
	//-------
	cache_get_value_name_int(0, "AdminLevel", playerData[playerid][pAdminLevel]);
	cache_get_value_name_int(0, "Cash", playerData[playerid][pCash]);
	return true;
}

function:RegisterLoginScreen(playerid)
{
	PlayerTextDrawSetSelectable(playerid, KayitGiris[7][playerid], true);
	SetSpawnInfo(playerid, NO_TEAM, DEFAULT_SKIN, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	//---
	new query[128], Cache:getQuery;
	mysql_format(conn, query, sizeof(query), "SELECT * FROM `oyuncular` WHERE `Nick` LIKE '%e'", GetPlayerNameEx(playerid));
	getQuery = mysql_query(conn, query);
	if(cache_num_rows())
	{
		playerData[playerid][pRuleReading] = -1;

		PlayerTextDrawSetString(playerid, KayitGiris[2][playerid], "~l~Bu kullanici adina ait hesap ~b~~h~mevcut~l~.");
		PlayerTextDrawSetString(playerid, KayitGiris[6][playerid], GetPlayerNameEx(playerid));
		PlayerTextDrawSetString(playerid, KayitGiris[7][playerid], "GIRIS YAP");
		PlayerTextDrawShow(playerid, KayitGiris[12][playerid]);

		playerData[playerid][pRegisterOrLogin] = LOGIN_METHOD;
		GetFirstVariable(playerid);
	}
	else
	{
		playerData[playerid][pRuleReading] = READING_RULE_TIME;

		PlayerTextDrawSetString(playerid, KayitGiris[2][playerid], "~l~Bu kullanici adina ait hesap ~r~~h~yok~l~.");
		PlayerTextDrawSetString(playerid, KayitGiris[6][playerid], GetPlayerNameEx(playerid));
		PlayerTextDrawSetString(playerid, KayitGiris[7][playerid], "KAYIT OL");
		playerData[playerid][pRegisterOrLogin] = REGISTER_METHOD;
	}

	cache_delete(getQuery);

	for(new i ; i < sizeof(KayitGiris); i ++)
	{
		if(i == 12) {continue;}
		PlayerTextDrawShow(playerid, KayitGiris[i][playerid]);
	}
	SelectTextDraw(playerid, 0xFFFF00FF);
	return true;
}

function:ResetPlayerVariables(playerid)
{
	playerData[playerid][pSQLID] = 0;
	playerData[playerid][pAdminLevel] = 0;
	playerData[playerid][pRegisterOrLogin] = 0;
	playerData[playerid][pCash] = 0;
	playerData[playerid][pFirstLogin] = false;
	playerData[playerid][pRuleReading] = READING_RULE_TIME;
	playerData[playerid][pRoom] = ROOM_EMPTY;
	playerData[playerid][pSpawnProtect] = false;
	format(playerData[playerid][pPassword], 30, "");
	//----
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 999);
	//----
	//TogglePlayerSpectating(playerid, true);
	return true;
}

function:MovePlayerScreen(playerid)
{
	InterpolateCameraPos(playerid, 2159.720947, 2155.392089, 10.163599, 2270.509765, 2127.194824, 47.957729, 50000);
	InterpolateCameraLookAt(playerid, 2164.625244, 2154.479492, 10.501465, 2275.256103, 2128.061767, 46.646144, 50000);
	return true;
}

function:SpawnEx(playerid)
{
	SpawnPlayer(playerid);
	MovePlayerScreen(playerid);
	ApplyLoginEffect(playerid);
	return true;
}

function:StopAllTimers(playerid)
{
	KillTimer(GirisEfektSondur[playerid]);
	KillTimer(KayitGirisEkrani[playerid]);
	return true;
}

function: UpdateRuleTiming(playerid)
{
	if(playerData[playerid][pRuleReading] < 1)
	{
		KillTimer(KurallariOku[playerid]);
		//--
		PlayerTextDrawHide(playerid, KayitGiris[7][playerid]);
		PlayerTextDrawSetSelectable(playerid, KayitGiris[7][playerid], true);
		PlayerTextDrawShow(playerid, KayitGiris[7][playerid]);

		if(playerData[playerid][pRuleReading] <= 0)
		{
			if(SearchDatabaseByName(GetPlayerNameEx(playerid)) == 0)
			{
				new query[128];
				mysql_format(conn, query, sizeof(query), "INSERT INTO `oyuncular` (`Nick`, `Password`, `Date`) VALUES ('%e', sha1('%e'), '%d')", GetPlayerNameEx(playerid), playerData[playerid][pPassword], gettime());
				mysql_query(conn, query);

				Dialog_Show(playerid, EMPTY_DIALOG, DIALOG_STYLE_MSGBOX, "{BB3434}>{E11F1F}>{FF5C5C}>{FFFFFF} Bilgilendirme Kutucuğu", "• Hesap şifreniz otomatik olarak getirildi, GİRİŞ YAP butonuna basabilirsiniz.\n\n{7C7C7C}** Kurallara uygun şekilde davranmayı unutmayın...", "{FF0000}OK", "");
				RegisterLoginScreen(playerid);
			}
		}
	}
	else
	{
		playerData[playerid][pRuleReading]--;
	}
	ShowServerRules(playerid);
	return true;
}

function:SearchDatabaseByName(name[])
{
    new query[128], bool:loop = true, Cache:queryData;
    mysql_format(conn, query, sizeof(query), "SELECT * FROM `oyuncular` WHERE `Nick` = '%e'", name);
    queryData = mysql_query(conn, query);
    if(cache_num_rows() == 0){ loop = false; }
    cache_delete(queryData);
    return _:loop;
}

//------- DIALOG'S -------

Dialog:SUNUCU_KURALLARI(playerid, response, listitem, inputtext[])
{
	if(playerData[playerid][pRuleReading] > 0)
	{
		ShowServerRules(playerid);
	}
	return true;
}

Dialog:KAYIT_MENUSU(playerid, response, listitem, inputtext[])
{
	if(!response) return true;
	if(strlen(inputtext) < 6) return HazirKayitGirisMenusu(playerid, REGISTER_METHOD, "Girdiğiniz şifre 6 karakterin altında olamaz.");
	if(strlen(inputtext) > 32) return HazirKayitGirisMenusu(playerid, REGISTER_METHOD, "Girdiğiniz şifre 32 karakterin üzerinde olamaz.");

	format(playerData[playerid][pPassword], 30, inputtext);
	if(playerData[playerid][pRuleReading] >= READING_RULE_TIME){

		PlayerTextDrawHide(playerid, KayitGiris[7][playerid]);
		PlayerTextDrawSetSelectable(playerid, KayitGiris[7][playerid], false);
		PlayerTextDrawShow(playerid, KayitGiris[7][playerid]);
		PlayerTextDrawSetString(playerid, KayitGiris[7][playerid], "GIRIS YAP");
		Dialog_Show(playerid, EMPTY_DIALOG, DIALOG_STYLE_MSGBOX, "{45A93C}>{34DE25}>{61FC53}>{FFFFFF} Bilgilendirme Kutucuğu", "{FF0000}•{FFFFFF} Harika, kayıt işlemine devam edebilmek için bir adım kaldı! Şimdi {29C4D6}OYUN KURALLARI{FFFFFF} seçeneğine tıklayın...", "OK", "");
		return true;
	}
	if(playerData[playerid][pRuleReading] <= 0)
	{
		if(SearchDatabaseByName(GetPlayerNameEx(playerid)) == 0)
		{
			new query[128];
			mysql_format(conn, query, sizeof(query), "INSERT INTO `oyuncular` (`Nick`, `Password`, `Date`) VALUES ('%e', sha1('%e'), '%d')", GetPlayerNameEx(playerid), playerData[playerid][pPassword], gettime());
			mysql_query(conn, query);

			Dialog_Show(playerid, EMPTY_DIALOG, DIALOG_STYLE_MSGBOX, "{BB3434}>{E11F1F}>{FF5C5C}>{FFFFFF} Bilgilendirme Kutucuğu", "• Hesap şifreniz otomatik olarak getirildi, GİRİŞ YAP butonuna basabilirsiniz.\n\n{7C7C7C}** Kurallara uygun şekilde davranmayı unutmayın...", "{FF0000}OK", "");
			RegisterLoginScreen(playerid);
		}
	}
	return true;
}


Dialog:GIRIS_MENUSU(playerid, response, listitem, inputtext[])
{
	if(!response) return true;
	
	LoginMethodControl(playerid, inputtext);

	return true;
}

//------- CALLBACKS -------

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == KayitGiris[7][playerid])
	{
		switch(playerData[playerid][pRegisterOrLogin])
		{
			case REGISTER_METHOD, LOGIN_METHOD:
			{
				HazirKayitGirisMenusu(playerid, playerData[playerid][pRegisterOrLogin], "");
	    	}
	    	default: Kick(playerid);
    	}
    }
    else if(playertextid == KayitGiris[8][playerid])
    {
    	if(playerData[playerid][pPassword] >= 6)
    	{
	    	if(playerData[playerid][pRuleReading] == READING_RULE_TIME && SearchDatabaseByName(GetPlayerNameEx(playerid)) == 0)
	    	{
	    		KurallariOku[playerid] = SetTimerEx("UpdateRuleTiming", 1000, true, "i", playerid);
	    	}
	    	else if(SearchDatabaseByName(GetPlayerNameEx(playerid)) == 1)
	    	{
	    		playerData[playerid][pRuleReading] = -1;
	    	}
	    	ShowServerRules(playerid);
    	}
    	else
    	{
    		Dialog_Show(playerid, EMPTY_DIALOG, DIALOG_STYLE_MSGBOX, "{BB3434}>{E11F1F}>{FF5C5C}>{FFFFFF} Bilgilendirme Kutucuğu", "{FFFFFF}• Öncelik olarak bir şifreye ihtiyacınız var. {CDCDCD}KAYIT OL{FFFFFF} butonuna tıklayın ve şifrenizi tanımlayın.", "{FF0000}OK", "");
    	}
    }
    else if(playertextid == KayitGiris[12][playerid])
    {
    	Dialog_Show(playerid, EMPTY_DIALOG, DIALOG_STYLE_MSGBOX, "{008710}>{00BA16}>{00FA1D}>{FFFFFF} Hesap Sizin Mi?", "{FFFFFF}\
    		Bu sizin hesabınız değilse, lütfen SA-MP başlatıcısında takma\nadınızı değiştirin ve sunucuya yeniden girin.\n\n\
    		Henüz başkası tarafından kaydedilmemiş bir nick bulmaya çalışın.\
    	", "OK", "");
    }
    return true;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(_:clickedid == INVALID_TEXT_DRAW)
    {
    	switch(playerData[playerid][pRegisterOrLogin])
    	{
        	case REGISTER_METHOD, LOGIN_METHOD:SelectTextDraw(playerid, 0xFFFF00FF);
    	}
    }
    return true;
}

public OnGameModeInit()
{
    LoadGamemodeSettings();
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return true;
}

public OnGameModeExit()
{
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(playerData[playerid][pRegisterOrLogin] != AFTER_LOGIN_METHOD)
	{
		SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
		SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
		SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
		
		TogglePlayerSpectating(playerid, true);
		SetTimerEx("SpawnEx", 1000, false, "i", playerid);
	}
	else
	{
		SetSpawnInfo(playerid, NO_TEAM, DEFAULT_SKIN, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}
	return true;
}

public OnPlayerSpawn(playerid)
{
	if(playerData[playerid][pRoom] == ROOM_FREEROAM && playerData[playerid][pRegisterOrLogin] == AFTER_LOGIN_METHOD)
	{
		new randomspawn = random(sizeof(SPAWN_POSITIONS));SetPlayerPos(playerid, SPAWN_POSITIONS[randomspawn][0], SPAWN_POSITIONS[randomspawn][1], \
			SPAWN_POSITIONS[randomspawn][2]); SetPlayerFacingAngle(playerid, SPAWN_POSITIONS[randomspawn][3]); SetCameraBehindPlayer(playerid);
		//-----------
		GivePlayerToFreeroamWeapons(playerid, ReplacedRandomFunc(1)); SetPlayerArmedWeapon(playerid, 0);

		playerData[playerid][pSpawnProtect] = true;
	}
	else if(playerData[playerid][pRoom] == ROOM_EMPTY)
	{
		MovePlayerScreen(playerid);
	}
	return true;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(playerData[playerid][pRoom] == ROOM_FREEROAM && playerData[playerid][pRegisterOrLogin] == AFTER_LOGIN_METHOD)
	{
		if(playerData[playerid][pSpawnProtect] == true)
		{
			return false;
		}
	}

	return true;
}

public OnPlayerUpdate(playerid)
{
	if(playerData[playerid][pSpawnProtect] == true)
	{
		if(GetPlayerSpeed(playerid) > 1)
		{
			playerData[playerid][pSpawnProtect] = false;
		}
	}
	return true;
}

public OnPlayerConnect(playerid)
{
	LoadPlayerTextDraws(playerid);
	ResetPlayerVariables(playerid);
	//--
	StopAllTimers(playerid);
	SetPVarInt(playerid, "EffectValue", 255);
	return true;
}

public OnPlayerDisconnect(playerid, reason)
{
	StopAllTimers(playerid);
	//--
	PlayerTextDrawDestroy(playerid, SureliKararti[playerid]);
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SendDeathMessage(killerid, playerid, reason);
	return true;
}

//------- COMMAND'S --------

CMD:kill(playerid, params[])
{
	SetPlayerHealth(playerid, 0.0);
	return true;
}

CMD:a(playerid, params[])
{
	if(playerData[playerid][pAdminLevel] < 1) return DeniedAuthority(playerid);
	if(isnull(params)) return KomutBilgisi(playerid, "/a(dmin) [metin girin]");

	foreach(new i : Player)
	{
		if(playerData[i][pAdminLevel] > 0)
		{
			SendClientMessageEx(i, 0xe84a4aFF, "** Admin %s: %s", GetPlayerNameEx(playerid), params);
		}
	}
	return true;
}
