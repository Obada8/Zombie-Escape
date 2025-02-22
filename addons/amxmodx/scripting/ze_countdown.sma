#include <zombie_escape>

// Setting File
new const ZE_SETTING_RESOURCES[] = "zombie_escape.ini"

// Defines
#define SOUND_MAX_LENGTH 64
#define TASK_COUNTDOWN 2010

// Default Countdown Sounds
new const szCountDownSound[][] =
{
	"zombie_escape/1.wav",
	"zombie_escape/2.wav",
	"zombie_escape/3.wav",
	"zombie_escape/4.wav",
	"zombie_escape/5.wav",
	"zombie_escape/6.wav",
	"zombie_escape/7.wav",
	"zombie_escape/8.wav",
	"zombie_escape/9.wav",
	"zombie_escape/10.wav"
}

// Dynamic Arrays
new Array:g_szCountDownSound

// Variables
new g_iCountDown

public plugin_precache()
{
	// Initialize arrays
	g_szCountDownSound = ArrayCreate(SOUND_MAX_LENGTH, 1)
	
	// Load from external file
	amx_load_setting_string_arr(ZE_SETTING_RESOURCES, "Sounds", "COUNT DOWN", g_szCountDownSound)
	
	// If we couldn't load custom sounds from file, use and save default ones
	new iIndex
	
	if (ArraySize(g_szCountDownSound) == 0)
	{
		for (iIndex = 0; iIndex < sizeof szCountDownSound; iIndex++)
		{
			// Get Defaults Sounds and Store them in the Array
			ArrayPushString(g_szCountDownSound, szCountDownSound[iIndex])
		}
		
		// Save values stored in Array to External file
		amx_save_setting_string_arr(ZE_SETTING_RESOURCES, "Sounds", "COUNT DOWN", g_szCountDownSound)
	}
	
	// Precache sounds stored in the Array
	new szSound[SOUND_MAX_LENGTH]
	
	for (iIndex = 0; iIndex < ArraySize(g_szCountDownSound); iIndex++)
	{
		ArrayGetString(g_szCountDownSound, iIndex, szSound, charsmax(szSound))
		precache_sound(szSound)
	}
}

public plugin_init()
{
	register_plugin("[ZE] Sound Countdown", ZE_VERSION, AUTHORS)
	
	// Map restart event
	register_event("TextMsg", "Map_Restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in", "2=#Round_Draw")
}

public ze_game_started()
{
	if (ze_get_round_number() == 1)
	{
		// 2 is Hardcoded Value, It's Fix for the countdown to work correctly first round
		g_iCountDown = get_member_game(m_iIntroRoundTime) - 2
	}
	else
	{
		// 3 is Hardcoded Value, It's Fix for the countdown to work correctly after first round
		g_iCountDown = get_member_game(m_iIntroRoundTime) - 3
	}
	
	set_task(1.0, "Countdown_Start", TASK_COUNTDOWN, _, _, "b")
}

public Countdown_Start()
{
	// Check gamemode is started or not yet?
	if (ze_is_gamemode_started())
	{
		remove_task(TASK_COUNTDOWN) // Remove the task
		return // Block the execution of the blew code	
	}

	if ((g_iCountDown - 1 < 0) || !ze_is_game_started())
	{
		remove_task(TASK_COUNTDOWN) // Remove the task
		return // Block the execution of the blew code
	}
	
	// Start the count down when remains 10 seconds
	if (g_iCountDown <= 10)
	{
		static szSound[SOUND_MAX_LENGTH]
		ArrayGetString(g_szCountDownSound, g_iCountDown - 1, szSound, charsmax(szSound))
		PlaySound(0, szSound)
	}
	
	g_iCountDown--
}

public ze_roundend(WinTeam)
{
	// At round end, remove countdown task to block interference next round
	remove_task(TASK_COUNTDOWN)
}

public Map_Restart()
{
	// At map restart, remove countdown task to block interference next rounds
	remove_task(TASK_COUNTDOWN)
}