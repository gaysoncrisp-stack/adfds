#include <stdint.h>
#include <cstddef>
#include <cstdlib>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <thread>
#include <atomic>
#include <mutex>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "dobby.h"
#import <objc/runtime.h>
#include <ptrauth.h>

#include "../il2cpp/il2cpp-types.h"
#include "KittyMemory.hpp"
#include "KittyUtils.hpp"
#include "KittyInclude.hpp"

#include <string>
#include <locale>
#include <codecvt>
#include <sstream>
#include <dlfcn.h>
#include <algorithm>
#include <../monoString.h>

#define STRIP_FP(p) (__has_feature(ptrauth_calls) ? ptrauth_strip((void*)(p), ptrauth_key_function_pointer) : (void*)(p))

std::unordered_map<std::string, std::unordered_map<std::string, Il2CppClass*>> classMap;
std::unordered_map<std::string, Il2CppImage*> imageMap;

std::string il2cpp_string_to_std(
    Il2CppString* str,
    Il2CppChar* (*string_chars)(Il2CppString*),
    int32_t (*string_length)(Il2CppString*)
) {
    if (!str) return "";
    auto chars = string_chars(str);
    auto len = string_length(str);
    std::u16string u16(reinterpret_cast<const char16_t*>(chars), len);
    std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> convert;
    return convert.to_bytes(u16);
}

static inline std::vector<std::string> itemIDs = {
    "item_ac_cola",
    "item_alphablade",
    "item_anti_gravity_grenade",
    "item_apple",
    "item_arena_pistol",
    "item_arena_shotgun",
    "item_arrow",
    "item_arrow_bomb",
    "item_arrow_heart",
    "item_arrow_lightbulb",
    "item_arrow_teleport",
    "item_axe",
    "item_backpack",
    "item_backpack_black",
    "item_backpack_green",
    "item_backpack_large_base",
    "item_backpack_large_basketball",
    "item_backpack_large_clover",
    "item_backpack_pink",
    "item_backpack_realistic",
    "item_backpack_small_base",
    "item_backpack_white",
    "item_backpack_with_flashlight",
    "item_balloon",
    "item_balloon_heart",
    "item_banana",
    "item_banana_chips",
    "item_baseball_bat",
    "item_beans",
    "item_big_cup",
    "item_bighead_larva",
    "item_bloodlust_vial",
    "item_boombox",
    "item_boombox_neon",
    "item_boomerang",
    "item_box_fan",
    "item_brain_chunk",
    "item_broccoli_grenade",
    "item_broccoli_shrink_grenade",
    "item_broom",
    "item_broom_halloween",
    "item_burrito",
    "item_calculator",
    "item_cardboard_box",
    "item_ceo_plaque",
    "item_clapper",
    "item_cluster_grenade",
    "item_coconut_shell",
    "item_cola",
    "item_cola_large",
    "item_company_ration",
    "item_company_ration_heal",
    "item_cracker",
    "item_crossbow",
    "item_crossbow_heart",
    "item_crowbar",
    "item_cutie_dead",
    "item_d20",
    "item_demon_sword",
    "item_disc",
    "item_disposable_camera",
    "item_drill",
    "item_drill_neon",
    "item_dynamite",
    "item_dynamite_cube",
    "item_egg",
    "item_electrical_tape",
    "item_eraser",
    "item_finger_board",
    "item_flamethrower_skull",
    "item_flamethrower_skull_ruby",
    "item_flaregun",
    "item_flashbang",
    "item_flashlight",
    "item_flashlight_mega",
    "item_flashlight_red",
    "item_flipflop_realistic",
    "item_floppy3",
    "item_floppy5",
    "item_football",
    "item_friend_launcher",
    "item_frying_pan",
    "item_gameboy",
    "item_glowstick",
    "item_goldbar",
    "item_goldcoin",
    "item_goop",
    "item_goopfish",
    "item_great_sword",
    "item_grenade",
    "item_grenade_gold",
    "item_grenade_launcher",
    "item_guided_boomerang",
    "item_harddrive",
    "item_hatchet",
    "item_hawaiian_drum",
    "item_heart_chunk",
    "item_heart_gun",
    "item_heartchocolatebox",
    "item_hh_key",
    "item_hookshot",
    "item_hookshot_sword",
    "item_hoverpad",
    "item_impulse_grenade",
    "item_jetpack",
    "item_keycard",
    "item_lance",
    "item_landmine",
    "item_large_banana",
    "item_megaphone",
    "item_mug",
    "item_moneygun",
    "item_nut",
    "item_ogre_hands",
    "item_ore_copper_l",
    "item_ore_copper_m",
    "item_ore_copper_s",
    "item_ore_gold_l",
    "item_ore_gold_m",
    "item_ore_gold_s",
    "item_ore_hell",
    "item_ore_silver_l",
    "item_ore_silver_m",
    "item_ore_silver_s",
    "item_painting_canvas",
    "item_paperpack",
    "item_pelican_case",
    "item_pickaxe",
    "item_pickaxe_cny",
    "item_pickaxe_cube",
    "item_pickaxe_realistic",
    "item_pinata_bat",
    "item_pipe",
    "item_plunger",
    "item_pogostick",
    "item_police_baton",
    "item_portable_teleporter",
    "item_prop_scanner",
    "item_pumpkin_bomb",
    "item_pumpkin_pie",
    "item_pumpkinjack",
    "item_pumpkinjack_small",
    "item_quest_gy_skull",
    "item_quest_gy_skull_special",
    "item_quest_hlal_brain",
    "item_quest_hlal_eyeball",
    "item_quest_hlal_flesh",
    "item_quest_hlal_heart",
    "item_quest_key_graveyard",
    "item_quest_vhs",
    "item_quest_vhs_backlots",
    "item_quest_vhs_basement",
    "item_quest_vhs_cave",
    "item_quest_vhs_circus_day",
    "item_quest_vhs_circus_ext",
    "item_quest_vhs_circus_fac",
    "item_quest_vhs_dam_facility",
    "item_quest_vhs_dam_servers",
    "item_quest_vhs_dark_forest",
    "item_quest_vhs_forest",
    "item_quest_vhs_foundation",
    "item_quest_vhs_graveyard",
    "item_quest_vhs_haunted_house",
    "item_quest_vhs_hell",
    "item_quest_vhs_lab",
    "item_quest_vhs_lake",
    "item_quest_vhs_lobby",
    "item_quest_vhs_mines",
    "item_quest_vhs_office",
    "item_quest_vhs_office_basement",
    "item_quest_vhs_sewers",
    "item_quiver",
    "item_quiver_heart",
    "item_radioactive_broccoli",
    "item_randombox_mobloot_big",
    "item_randombox_mobloot_medium",
    "item_randombox_mobloot_small",
    "item_randombox_mobloot_weapons",
    "item_randombox_mobloot_zombie",
    "item_rare_card",
    "item_revolver",
    "item_revolver_ammo",
    "item_revolver_gold",
    "item_ring_buoy",
    "item_robo_monke",
    "item_rope",
    "item_rpg",
    "item_rpg_ammo",
    "item_rpg_ammo_egg",
    "item_rpg_ammo_spear",
    "item_rpg_cny",
    "item_rpg_easter",
    "item_rpg_spear",
    "item_rubberducky",
    "item_ruby",
    "item_saddle",
    "item_scanner",
    "item_scissors",
    "item_server_pad",
    "item_shield",
    "item_shield_bones",
    "item_shield_police",
    "item_shield_viking_1",
    "item_shield_viking_2",
    "item_shield_viking_3",
    "item_shield_viking_4",
    "item_shotgun",
    "item_shotgun_ammo",
    "item_shovel",
    "item_shredder",
    "item_shrinking_broccoli",
    "item_snowball",
    "item_stapler",
    "item_stash_grenade",
    "item_stick_armbones",
    "item_stick_bone",
    "item_sticker_dispenser",
    "item_sticky_dynamite",
    "item_stinky_cheese",
    "item_tablet",
    "item_tapedispenser",
    "item_tele_grenade",
    "item_teleport_gun",
    "item_theremin",
    "item_timebomb",
    "item_toilet_paper",
    "item_toilet_paper_mega",
    "item_toilet_paper_roll_empty",
    "item_token_circus",
    "item_trampoline",
    "item_treestick",
    "item_tripwire_explosive",
    "item_trophy",
    "item_turkey_leg",
    "item_turkey_whole",
    "item_ukulele",
    "item_ukulele_gold",
    "item_umbrella",
    "item_umbrella_clover",
    "item_umbrella_squirrel",
    "item_upsidedown_loot",
    "item_uranium_chunk_l",
    "item_uranium_chunk_m",
    "item_uranium_chunk_s",
    "item_viking_hammer",
    "item_viking_hammer_twilight",
    "item_whoopie",
    "item_wood_log",
    "item_zipline_gun",
    "item_zombie_meat",
};

static std::string g_itemId = "item_cola";
static std::atomic<bool> g_cfgReady{false};
static std::atomic<bool> g_fetchStarted{false};
static float g_scale = 11.f, g_sat = 11.f, g_hue = 11.f;

static Il2CppChar* (*string_chars)(Il2CppString*)   = nullptr;
static int32_t    (*string_length)(Il2CppString*)   = nullptr;
static Il2CppString* (*s_string_new)(const char*) = nullptr;
static Il2CppClass*  (*s_object_get_class)(Il2CppObject*) = nullptr;
static FieldInfo*    (*s_class_get_field_from_name)(Il2CppClass*, const char*) = nullptr;
static void          (*s_field_get_value)(Il2CppObject*, FieldInfo*, void*) = nullptr;
static void          (*s_field_set_value)(Il2CppObject*, FieldInfo*, void*) = nullptr;
static MethodInfo*   (*s_get_method_from_name)(Il2CppClass*, const char*, int) = nullptr;
static Il2CppObject* (*s_type_get_object)(const Il2CppType*) = nullptr;
static Il2CppObject* (*s_runtime_invoke)(const MethodInfo*, void*, void**, Il2CppException**) = nullptr;
static Il2CppObject* (*s_value_box)(Il2CppClass*, void*) = nullptr;
static Il2CppClass*  (*s_get_class_from_name)(const char*, const char*) = nullptr;
using t_class_get_methods   = const MethodInfo*(*)(Il2CppClass*, void**);
using t_class_get_namespace = const char*(*)(Il2CppClass*);
using t_class_get_name      = const char*(*)(Il2CppClass*);
using t_type_get_name       = const char*(*)(const Il2CppType*);
static t_class_get_methods   s_class_get_methods   = nullptr;
static t_class_get_namespace s_class_get_namespace = nullptr;
static t_class_get_name      s_class_get_name      = nullptr;
static t_type_get_name       s_type_get_name       = nullptr;
static void* (*s_object_unbox)(Il2CppObject*) = nullptr;

static inline Il2CppString* CreateMonoString(const char* s) { return s_string_new ? s_string_new(s) : nullptr; }

static inline bool GetFieldRaw(Il2CppObject* obj, const char* name, void* outPtr) {
    if (!obj || !s_object_get_class || !s_class_get_field_from_name || !s_field_get_value) return false;
    Il2CppClass* k = s_object_get_class(obj); if (!k) return false;
    FieldInfo* f = s_class_get_field_from_name(k, name); if (!f) return false;
    s_field_get_value(obj, f, outPtr); return true;
}
static inline bool SetFieldRaw(Il2CppObject* obj, const char* name, const void* inPtr) {
    if (!obj || !s_object_get_class || !s_class_get_field_from_name || !s_field_set_value) return false;
    Il2CppClass* k = s_object_get_class(obj); if (!k) return false;
    FieldInfo* f = s_class_get_field_from_name(k, name); if (!f) return false;
    s_field_set_value(obj, f, (void*)inPtr); return true;
}

static Il2CppClass* AnimalCompanyAPI = nullptr;
static Il2CppClass* GameObject = nullptr;
static Il2CppClass* Resources = nullptr;
static Il2CppClass* Component        = nullptr;
static Il2CppClass* GrabbableItem    = nullptr;
static Il2CppClass* GrabbableObject  = nullptr;
static Il2CppClass* NetSpectator     = nullptr;
static Il2CppClass* NetPlayer     = nullptr;
static Il2CppClass* NetworkManager   = nullptr;

static Il2CppClass* NetworkObjectPrefabData   = nullptr;
static Il2CppClass* NetworkPrefabTable   = nullptr;
static Il2CppClass* NetworkObject   = nullptr;
static Il2CppClass* NetworkRunner   = nullptr;
static Il2CppClass* NetworkProjectConfig = nullptr;

static Il2CppClass* AuthenticationValues   = nullptr;
static Il2CppClass* PrefabGenerator  = nullptr;
static Il2CppClass* BackpackItem     = nullptr;
static Il2CppClass* AuthCommands     = nullptr;
static Il2CppClass* Quiver     = nullptr;
static Il2CppClass* GrabbableItemState     = nullptr;
static Il2CppClass* JSONNode     = nullptr;
static Il2CppClass* Session     = nullptr;
static Il2CppClass* NutDropManager     = nullptr;
static Il2CppClass* NetSessionRPCs     = nullptr;
static Il2CppClass* NetworkSessionManager     = nullptr;
static Il2CppClass* App           = nullptr;
static Il2CppClass* AppState      = nullptr;
static Il2CppClass* AppStartup      = nullptr;
static Il2CppClass* StatePrimitiveGeneric = nullptr;
static Il2CppClass* GameplayItemEquippingConfig = nullptr;
static Il2CppClass* HeartGun = nullptr;
static Il2CppClass* AttachedItemAnchor = nullptr;
static Il2CppClass* ChoppableTreeManager = nullptr;
static Il2CppClass* RoboMonkeItem = nullptr;
static Il2CppClass* Trampoline = nullptr;
static Il2CppClass* TeleGrenade = nullptr;
static Il2CppClass* GrenadeLauncher = nullptr;
static Il2CppClass* MobController = nullptr;
static Il2CppClass* LakeJobPartTwo = nullptr;
static Il2CppClass* HordeMobSpawner = nullptr;
static Il2CppClass* MomBossItemSpawner = nullptr;
static Il2CppClass* PickupManager = nullptr;
static Il2CppClass* FlareGun = nullptr;
static Il2CppClass* AppPrefabPool = nullptr;
static Il2CppClass* PrefabPool = nullptr;
static Il2CppClass* Transform = nullptr;
static Il2CppClass* NetObjectSpawnGroup = nullptr;
static Il2CppClass* RandomPrefab = nullptr;
static Il2CppClass* HordeMobController = nullptr;
static Il2CppClass* MomBossGameMusicalChair = nullptr;
static Il2CppClass* Balloon = nullptr;
static Il2CppClass* HttpRequestAdapter = nullptr;
static Il2CppClass* CutieController = nullptr;
static Il2CppClass* UserStashAndLoadoutSaveMediator = nullptr;
static Il2CppClass* NetworkBehaviour;

struct Vector3 { float x,y,z; };
struct Quaternion { float x,y,z,w; };

static void (*s_field_static_get_value)(FieldInfo*, void*) = nullptr;

using t_GO_SetActive              = void(*)(Il2CppObject*, bool);
using t_GO_Find           = Il2CppObject*(*)(Il2CppString*);
using t_GO_GetComponent           = Il2CppObject*(*)(Il2CppObject*, Il2CppObject*);
using t_GO_GetComponentInChildren = Il2CppObject*(*)(Il2CppObject*, Il2CppObject*);
using t_GO_AddComponent = Il2CppObject*(*)(Il2CppObject*, Il2CppObject*);
using t_SpawnItem                 = Il2CppObject*(*)(Il2CppString*, Vector3, Quaternion, void*);

static t_GO_Find           GO_Find = nullptr;
static t_GO_SetActive              GO_SetActive = nullptr;
static t_GO_GetComponent           GO_GetComponent = nullptr;
static t_GO_GetComponentInChildren GO_GetComponentInChildren = nullptr;

static t_GO_AddComponent GO_AddComponent = nullptr;

static t_SpawnItem                 g_SpawnItem = nullptr;

static std::atomic<bool> g_cfgDespawnItems{false};
static std::atomic<bool> g_cfgKickAll{false};
static std::atomic<bool> g_cfgFlingAll{false};
static std::atomic<bool> g_cfgPrefabSpammer{false};
static std::atomic<bool> g_cfgSpamNut{false};

static std::atomic<bool> g_cfgApplyBuff{false};
static std::atomic<bool> g_cfgAddMoney{false};
static std::atomic<bool> g_cfgItemSpammer{false};
static std::atomic<bool> g_cfgRandomColor{false};
static std::atomic<bool> g_cfgRandomItem{false};
static std::atomic<bool> g_cfgQuiverSpawn{false};
static std::atomic<bool> g_cfgQuiverSpam{false};
static std::atomic<bool> g_cfgActionSingle{false};
static std::atomic<bool> g_cfgActionLoop{false};
static std::atomic<bool> g_cfgRefreshPlayers{false};

static std::atomic<bool> g_cfgBackpackMode{false};

static std::atomic<bool> g_cfgItemSpamJiggle{false};
static std::atomic<bool> g_cfgContentsJiggle{false};
static std::atomic<bool> g_cfgActionForAll{false};
static std::atomic<bool> g_cfgActionForAllLoop{false};
static std::atomic<bool> g_cfgSpawnHeavyStick{false};
static std::atomic<bool> g_cfgSpawnValuableStick{false};
static std::atomic<bool> g_cfgSpawnStackedCrossbow{false};
static std::atomic<bool> g_cfgSpawnMobGrenade{false};

static std::atomic<int>  g_cfgHue{127};
static std::atomic<int>  g_cfgSat{127};
static std::atomic<int>  g_cfgScale{127};

static std::atomic<int>  g_cfgQHue{127};
static std::atomic<int>  g_cfgQSat{127};
static std::atomic<int>  g_cfgQScale{127};

static std::atomic<int>  g_buff{0};
static std::atomic<int>  g_netId{0};

static std::atomic<int>  g_crossbowStackAmmount{0};

static std::string       g_cfgItemId{"item_apple"};
static std::string       g_cfgPrefabId{"GiantRockObject"};
static std::string       g_cfgTargetPlayer{"Crisp2343"};
static std::string       g_cfgTargetAction{"Fling"};

static std::mutex        g_cfgMu;
static std::mutex        g_cfgMd;
static std::mutex        g_cfgMx;

static std::mutex        g_cfgMp;
static std::mutex        g_cfgMf;

static constexpr size_t kContainedItemCoreDataSize = 0x1C;
static constexpr size_t kQuiver_TempItemState_Offset = 0xB8;

static std::atomic<bool> g_pollStarted{false};
static const char*       kModCfgURL = "https://acapiforapk.onrender.com/api/mod";

Il2CppObject* runner = nullptr;
Il2CppObject* nmInstance = nullptr;

struct PlayerRefNative { int _index; };
struct LoadSceneParameters { int m_LoadSceneMode; int m_LocalPhysicsMode; };
struct ChildSpec 
{
    std::string itemId;
    int         ammo{0};
    int         colorHue{0};
    int         colorSat{0};
    int         scale{0};
};
static const int kContainedItemNetIdOffset = 0x4;
struct BackpackKV {
    short key;
    uint8_t value[64];
};
static std::vector<ChildSpec> g_cfgChildren;

static inline Il2CppObject* TypeOf(Il2CppClass* k) {
    return (k && s_type_get_object) ? s_type_get_object(&k->byval_arg) : nullptr;
}
static void _ApplyConfigNSDictionary(NSDictionary* d)
{
    if (!d) return;
    id v;

    v = d[@"itemSpammer"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgItemSpammer.store([(NSNumber*)v boolValue]);
    v = d[@"addMoney"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgAddMoney.store([(NSNumber*)v boolValue]);
    v = d[@"applyBuff"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgApplyBuff.store([(NSNumber*)v boolValue]);

    v = d[@"despawnItems"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgDespawnItems.store([(NSNumber*)v boolValue]);
    v = d[@"kickAll"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgKickAll.store([(NSNumber*)v boolValue]);
    v = d[@"flingAll"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgFlingAll.store([(NSNumber*)v boolValue]);
    v = d[@"prefabSpammer"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgPrefabSpammer.store([(NSNumber*)v boolValue]);
    v = d[@"spamNut"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSpamNut.store([(NSNumber*)v boolValue]);
    v = d[@"spawnHeavyStick"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSpawnHeavyStick.store([(NSNumber*)v boolValue]);
    v = d[@"spawnValuableStick"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSpawnValuableStick.store([(NSNumber*)v boolValue]);
    v = d[@"spawnStackedCrossbow"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSpawnStackedCrossbow.store([(NSNumber*)v boolValue]);
    v = d[@"spawnMobGrenade"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSpawnMobGrenade.store([(NSNumber*)v boolValue]);

    v = d[@"quiverSpam"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgQuiverSpam.store([(NSNumber*)v boolValue]);

    v = d[@"refreshPlayers"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgRefreshPlayers.store([(NSNumber*)v boolValue]);

    v = d[@"backPackmode"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgBackpackMode.store([(NSNumber*)v boolValue]);

    v = d[@"quiverSpawn"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgQuiverSpawn.store([(NSNumber*)v boolValue]);

    v = d[@"executeActionSingle"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgActionSingle.store([(NSNumber*)v boolValue]);
    v = d[@"executeActionLoop"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgActionLoop.store([(NSNumber*)v boolValue]);
    v = d[@"actionForAll"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgActionForAll.store([(NSNumber*)v boolValue]);
    v = d[@"actionForAllLoop"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgActionForAllLoop.store([(NSNumber*)v boolValue]);

    v = d[@"randomColor"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgRandomColor.store([(NSNumber*)v boolValue]);
    v = d[@"randomItem"];  if ([v isKindOfClass:[NSNumber class]]) g_cfgRandomItem .store([(NSNumber*)v boolValue]);
    v = d[@"itemSpamJiggle"];  if ([v isKindOfClass:[NSNumber class]]) g_cfgItemSpamJiggle .store([(NSNumber*)v boolValue]);

    v = d[@"hue"];        if ([v isKindOfClass:[NSNumber class]]) g_cfgHue  .store([(NSNumber*)v intValue]);
    v = d[@"saturation"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgSat  .store([(NSNumber*)v intValue]);
    v = d[@"scale"];      if ([v isKindOfClass:[NSNumber class]]) g_cfgScale.store([(NSNumber*)v intValue]);

    v = d[@"quiverHue"];        if ([v isKindOfClass:[NSNumber class]]) g_cfgQHue  .store([(NSNumber*)v intValue]);
    v = d[@"quiverSaturation"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgQSat  .store([(NSNumber*)v intValue]);
    v = d[@"quiverScale"];      if ([v isKindOfClass:[NSNumber class]]) g_cfgQScale.store([(NSNumber*)v intValue]);
    v = d[@"contentsJiggle"];      if ([v isKindOfClass:[NSNumber class]]) g_cfgContentsJiggle.store([(NSNumber*)v intValue]);

    v = d[@"buff"];      if ([v isKindOfClass:[NSNumber class]]) g_buff.store([(NSNumber*)v intValue]);
    v = d[@"netId"];      if ([v isKindOfClass:[NSNumber class]]) g_netId.store([(NSNumber*)v intValue]);

    v = d[@"crossbowStackAmmount"];      if ([v isKindOfClass:[NSNumber class]]) g_crossbowStackAmmount.store([(NSNumber*)v intValue]);

    v = d[@"itemId"];
    if ([v isKindOfClass:[NSString class]]) {
        std::lock_guard<std::mutex> lk(g_cfgMu);
        g_cfgItemId = [(NSString*)v UTF8String];
    }

    v = d[@"targetPlayer"];
    if ([v isKindOfClass:[NSString class]]) {
        std::lock_guard<std::mutex> lk(g_cfgMp);
        g_cfgTargetPlayer = [(NSString*)v UTF8String];
    }

    v = d[@"targetAction"];
    if ([v isKindOfClass:[NSString class]]) {
        std::lock_guard<std::mutex> lk(g_cfgMf);
        g_cfgTargetAction = [(NSString*)v UTF8String];
    }

    v = d[@"prefabId"];
    if ([v isKindOfClass:[NSString class]]) {
        std::lock_guard<std::mutex> lk(g_cfgMx);
        g_cfgPrefabId = [(NSString*)v UTF8String];
    }

    v = d[@"itemChildren"];
    if ([v isKindOfClass:[NSArray class]]) {
        std::vector<ChildSpec> tmp;
        for (id e in (NSArray*)v) {
            if (![e isKindOfClass:[NSDictionary class]]) continue;
            NSDictionary* cd = (NSDictionary*)e;

            NSString* iid = [cd objectForKey:@"itemId"];
            if (![iid isKindOfClass:[NSString class]]) continue;
            if ([iid length] == 0) continue;

            ChildSpec cs;
            cs.itemId   = [iid UTF8String];

            id av = cd[@"ammo"];       if ([av isKindOfClass:[NSNumber class]]) cs.ammo     = [(NSNumber*)av intValue];
            id hv = cd[@"colorHue"];   if ([hv isKindOfClass:[NSNumber class]]) cs.colorHue = [(NSNumber*)hv intValue];
            id sv = cd[@"colorSat"];   if ([sv isKindOfClass:[NSNumber class]]) cs.colorSat = [(NSNumber*)sv intValue];
            id sc = cd[@"scale"];      if ([sc isKindOfClass:[NSNumber class]]) cs.scale    = [(NSNumber*)sc intValue];

            tmp.push_back(cs);
        }
        std::lock_guard<std::mutex> lk(g_cfgMd);
        g_cfgChildren.swap(tmp);
    }
}
static void _ScheduleNextFetch(double seconds);

static void _FetchConfigOnce(void) {
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:kModCfgURL]];
        if (!url) { _ScheduleNextFetch(0.5); return; }

        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:5.0];
        [req setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
        [req setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];

        [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                        completionHandler:^(NSData *data, NSURLResponse *r, NSError *e) {
            @autoreleasepool {
                if (!e && data.length > 0) {
                    NSError *je = nil;
                    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&je];
                    if (!je && [obj isKindOfClass:[NSDictionary class]]) {
                        _ApplyConfigNSDictionary((NSDictionary*)obj);
                    }
                }
                _ScheduleNextFetch(0.25);
            }
        }] resume];
    }
}
static void _ScheduleNextFetch(double seconds) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        _FetchConfigOnce();
    });
}
static void StartConfigPoll() {
    bool expected = false;
    if (g_pollStarted.compare_exchange_strong(expected, true)) {
        _FetchConfigOnce();
    }
}
static inline uint8_t clamp_u8(float v) { if (v < 0.f) return 0; if (v > 255.f) return 255; return (uint8_t)v; }
static inline int8_t  clamp_i8(float v) { if (v < -128.f) return -128; if (v > 127.f) return 127; return (int8_t)v; }

typedef void (*t_NS_Update)(Il2CppObject* self);
static t_NS_Update orig_NS_Update = nullptr;

@interface ACFramePump : NSObject
@end
@implementation ACFramePump
@end

static CADisplayLink *g_displayLink = nil;
static ACFramePump   *g_framePump   = nil;

static bool buffDone;
static bool quiverDone;
static bool quiverDoneee;
static bool actionDone;
static bool refreshDone;

using Vec3 = Vector3;
using Quat = Quaternion;

template<typename T>
struct NullableT {
    bool hasValue;
    T    value;
};


static Il2CppClass* Revolver;
static Il2CppClass* Shotgun;
static Il2CppClass* GameplayItemState;

struct NetworkId { uint32_t Raw; };

struct NetworkBehaviourId { int Behaviour; NetworkId Object; };
struct NetworkObjectGuid {
    int64_t _data0;
    int64_t _data1;
};

struct NetworkPrefabId {
    uint32_t RawValue;
};


struct System_Nullable_1_UnityEngine_Vector3_ {
    bool has_value;
    Vector3 value;
};

struct System_Nullable_1_UnityEngine_Quaternion_ {
    bool has_value;
    Quaternion value;
};

struct System_Nullable_1_Fusion_PlayerRef_ {
    bool has_value;
    PlayerRefNative value;
};

static bool doneprefabspam;
static bool doneFetchingPrefabs;
static Il2CppClass* Crossbow;

static bool CrossbowsDone;
static bool crossbowDoneMod;
static Vector3 GetCamPosition()
{
    Vector3 zero{0.f, 0.f, 0.f};

    auto nm_f_instance = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
    if (!nm_f_instance || !nm_f_instance->methodPointer) return zero;
    auto get_instance  = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);

    Il2CppObject* nsInstance = get_instance();
    if (!nsInstance) return zero;

    auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
    if (!nm_get_position || !nm_get_position->methodPointer) return zero;
    auto get_position    = (Vector3(*)(Il2CppObject*))STRIP_FP(nm_get_position->methodPointer);

    Vector3 camPosition = get_position(nsInstance);

    return camPosition;
}
static Il2CppObject* SpawnItem(Il2CppString* item, Vector3 pos, int8_t scale, int8_t saturation, uint8_t hue, bool jelly = false)
{
        if (!g_SpawnItem) return nullptr;

        auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
        auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
        auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
        auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);
        auto mSetAllow   = s_get_method_from_name(GrabbableItem,   "set_allowAddToBag",   1);
        auto mSetJelly     = s_get_method_from_name(GrabbableObject, "RPC_SetJellyStrengthData",       1);

        if (!mComp_getGO || !mSetScale || !mSetSat || !mSetHue) return nullptr;

        Il2CppObject* grItemType = nullptr;
        if (s_type_get_object && GrabbableItem)
            grItemType = s_type_get_object(&GrabbableItem->byval_arg);

        Quaternion rot{0.f, 0.f, 0.f, 1.f};
        void* cb = nullptr;

        Il2CppObject* netObj = g_SpawnItem(item, pos, rot, cb);
        if (!netObj) return nullptr;

        auto get_gameObject = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(mComp_getGO->methodPointer);
        Il2CppObject* go = get_gameObject(netObj);
        if (!go || !grItemType) return nullptr;

        Il2CppObject* grComp =
            GO_GetComponentInChildren ? GO_GetComponentInChildren(go, grItemType) : nullptr;
        if (!grComp) return nullptr;

        ((void(*)(Il2CppObject*, int8_t ))STRIP_FP(mSetScale->methodPointer))(grComp, scale);
        ((void(*)(Il2CppObject*, int8_t ))STRIP_FP(mSetSat  ->methodPointer))(grComp, saturation);
        ((void(*)(Il2CppObject*, uint8_t))STRIP_FP(mSetHue  ->methodPointer))(grComp, hue);
        ((void(*)(Il2CppObject*, bool))STRIP_FP(mSetAllow  ->methodPointer))(grComp, true);
        if(jelly)
        {
            ((void(*)(Il2CppObject*, uint8_t)) STRIP_FP(mSetJelly  ->methodPointer))(grComp, 255);
        }

        return go;
}
static void FlingAll()
{
    Il2CppClass* NetPlayer      = classMap["AnimalCompany"]["NetPlayer"];
        if (!GameObject || !NetPlayer) return;

        MethodInfo* m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 2);
        void* pFind = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr;
        if (!pFind) {
            m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
            pFind  = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr;
        }
        if (!pFind) return;

        Il2CppObject* netPlayerType = s_type_get_object ? s_type_get_object(&NetPlayer->byval_arg) : nullptr;
        if (!netPlayerType) return;

        Il2CppArray* arr = nullptr;
        if (m_Find->parameters_count == 2) {
            using t_Find2 = Il2CppArray* (*)(Il2CppObject*, bool);
            arr = ((t_Find2)pFind)(netPlayerType, false);
        } else {
            using t_Find1 = Il2CppArray* (*)(Il2CppObject*);
            arr = ((t_Find1)pFind)(netPlayerType);
        }
        if (!arr) return;

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
        Il2CppObject* nsInstance = get_instance();

        auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
        auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
        Il2CppObject* vr = get_vrPlayer(nsInstance);

        MethodInfo* m_AddForce = s_get_method_from_name(NetPlayer, "RPC_AddForce", 1);
        if (!m_AddForce || !m_AddForce->methodPointer) return;
        using t_AddForce = void(*)(Il2CppObject*, Vector3);
        auto AddForce = (t_AddForce)STRIP_FP(m_AddForce->methodPointer);

        auto len  = arr->max_length;
        auto data = (Il2CppObject**)((uint8_t*)arr + sizeof(Il2CppArray));
        for (uint32_t i = 0; i < len; ++i) 
        {
            Il2CppObject* np = data[i];
            if (!np) continue;
            if (np != vr)
            {
                AddForce(np, Vector3{0.f, 99.f, 0.f});
            }
        }
}
static void TeamAll()
{
    MethodInfo* m_Destroy = s_get_method_from_name(NetworkRunner, "Despawn", 1);
    if (!m_Destroy || !m_Destroy->methodPointer) return;
    using t_Destroy = void(*)(Il2CppObject*, Il2CppObject*);
    auto Destroy = (t_Destroy)STRIP_FP(m_Destroy->methodPointer);

    Il2CppObject* netObjectType = TypeOf(NetworkObject);

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) 
    {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType(Type) not found");
            return;
        }
    }

    Il2CppException* exees = nullptr;
    void* argsFOT[1] = { netObjectType };
    Il2CppObject* arrPrefabs = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFOT, &exees);
    if (exees || !arrPrefabs) 
    {
        return;
    }

    Il2CppArray* arrp = (Il2CppArray*)arrPrefabs;
    Il2CppObject** elemss = (Il2CppObject**)((char*)arrp + sizeof(Il2CppArray));

    for (il2cpp_array_size_t i = 0; i < arrp->max_length; ++i) 
    {
        Il2CppObject* nosg = elemss[i];
        if (!nosg) continue;

        Destroy(runner, nosg);
    }    
}
static void TpAll()
{
     Il2CppClass* NetPlayer      = classMap["AnimalCompany"]["NetPlayer"];
        if (!GameObject || !NetPlayer) return;

        MethodInfo* m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 2);
        void* pFind = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr;
        if (!pFind) {
            m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
            pFind  = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr;
        }
        if (!pFind) return;

        Il2CppObject* netPlayerType = s_type_get_object ? s_type_get_object(&NetPlayer->byval_arg) : nullptr;
        if (!netPlayerType) return;

        Il2CppArray* arr = nullptr;
        if (m_Find->parameters_count == 2) {
            using t_Find2 = Il2CppArray* (*)(Il2CppObject*, bool);
            arr = ((t_Find2)pFind)(netPlayerType, false);
        } else {
            using t_Find1 = Il2CppArray* (*)(Il2CppObject*);
            arr = ((t_Find1)pFind)(netPlayerType);
        }
        if (!arr) return;

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
        Il2CppObject* nsInstance = get_instance();

        auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
        auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
        Il2CppObject* vr = get_vrPlayer(nsInstance);

        auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
        if (!nm_get_position || !nm_get_position->methodPointer) return;
        auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

        Vector3 camPosition = get_position(nsInstance);

        MethodInfo* m_Teleport = s_get_method_from_name(NetPlayer, "RPC_Teleport", 1);
        if (!m_Teleport || !m_Teleport->methodPointer) return;
        using t_Teleport = void(*)(Il2CppObject*, Vector3);
        auto Teleport = (t_Teleport)STRIP_FP(m_Teleport->methodPointer);

        auto len  = arr->max_length;
        auto data = (Il2CppObject**)((uint8_t*)arr + sizeof(Il2CppArray));
        for (uint32_t i = 0; i < len; ++i) 
        {
            Il2CppObject* np = data[i];
            if (!np) continue;
            if (np != vr)
            {
                Teleport(np, camPosition);
            }
        }
}
static void DespawnAll()
{
     Il2CppClass* GrabbableObject  = classMap["AnimalCompany"]["GrabbableObject"];
        if (!GameObject || !GrabbableObject) return;

        MethodInfo* m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 2);
        void* pFind = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr;
        if (!pFind) { m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 1); pFind = m_Find ? STRIP_FP(m_Find->methodPointer) : nullptr; }
        if (!pFind) return;

        Il2CppObject* goType = s_type_get_object ? s_type_get_object(&GrabbableObject->byval_arg) : nullptr;
        if (!goType) return;

        Il2CppArray* arr = nullptr;
        if (m_Find->parameters_count == 2) {
            using t_Find2 = Il2CppArray* (*)(Il2CppObject*, bool);
            arr = ((t_Find2)pFind)(goType, false);
        } else {
            using t_Find1 = Il2CppArray* (*)(Il2CppObject*);
            arr = ((t_Find1)pFind)(goType);
        }
        if (!arr) return;

        MethodInfo* m_Despawn = s_get_method_from_name(GrabbableObject, "RPC_Teleport", 1);
        if (!m_Despawn || !m_Despawn->methodPointer) return;
        using t_Despawn = void(*)(Il2CppObject*, Vector3);
        auto Despawn = (t_Despawn)STRIP_FP(m_Despawn->methodPointer);

        auto len  = arr->max_length;
        auto data = (Il2CppObject**)((uint8_t*)arr + sizeof(Il2CppArray));
        for (uint32_t i = 0; i < len; ++i) {
            Il2CppObject* obj = data[i];
            if (!obj) continue;
            Despawn(obj, GetCamPosition());
        }
}
static void NutSpammer()
{
    auto m_spawnNutDrops = s_get_method_from_name(NutDropManager, "SpawnNutDrops", 4);

        auto SpawnNutDrops = (Il2CppObject*(*)(int, Vector3, float, float))STRIP_FP(m_spawnNutDrops->methodPointer);

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        if (!nm_f_instance || !nm_f_instance->methodPointer) return;
        auto get_instance   = (Il2CppObject*(*)()) STRIP_FP(nm_f_instance->methodPointer);

        Il2CppObject* nsInstance = get_instance();
        if (!nsInstance) return;

        auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
        if (!nm_get_position || !nm_get_position->methodPointer) return;
        auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

        Vector3 camPosition = get_position(nsInstance);

        SpawnNutDrops(1000, camPosition, 10.f, 0.f);
}
static void Buff()
{
    KITTY_LOGI("caught apply buff trying to actually apply now");

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
        Il2CppObject* nsInstance = get_instance();

        auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
        auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
        Il2CppObject* vr = get_vrPlayer(nsInstance);

        auto nm_applyBuff  = s_get_method_from_name(NetPlayer, "RPC_ApplyBuff", 1);
        auto ApplyBuff = (void(*)(Il2CppObject*, int))STRIP_FP(nm_applyBuff->methodPointer);

        if(!buffDone)
        {
            ApplyBuff(vr, g_buff.load());
            buffDone = true;
        }
}
static void Money()
{
     KITTY_LOGI("caught add money trying to actually add now");

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
        Il2CppObject* nsInstance = get_instance();

        auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
        auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);

        Il2CppObject* vr = get_vrPlayer(nsInstance);

        auto nm_addMoney  = s_get_method_from_name(NetPlayer, "RPC_AddPlayerMoney", 1);
        auto AddPlayerMoney = (void(*)(Il2CppObject*, int))STRIP_FP(nm_addMoney->methodPointer);

        AddPlayerMoney(vr, 9999999);
}
static void ItemSpam()
{
        if (!g_SpawnItem) return;

        auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",     0);
        auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",  1);
        auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation",1);
        auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",       1);
        auto mSetJelly     = s_get_method_from_name(GrabbableObject, "RPC_SetJellyStrengthData",       1);

        if (!mComp_getGO || !mSetScale || !mSetSat || !mSetHue) return;

        Il2CppObject* grItemType = nullptr;
        if (s_type_get_object && GrabbableItem) 
        {
            grItemType = s_type_get_object(&GrabbableItem->byval_arg);
        }

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        if (!nm_f_instance || !nm_f_instance->methodPointer) return;
        auto get_instance   = (Il2CppObject*(*)()) STRIP_FP(nm_f_instance->methodPointer);

        Il2CppObject* nsInstance = get_instance();
        if (!nsInstance) return;

        auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
        if (!nm_get_position || !nm_get_position->methodPointer) return;
        auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

        Vector3 camPosition = get_position(nsInstance);
        Quaternion rot{0.f,0.f,0.f,1.f};
        void* cb = nullptr;

        std::string id;
        if (g_cfgRandomItem.load())
        {
            static size_t idx = 0;
            const size_t n = itemIDs.size();
            if (!n) return;
            id = itemIDs[idx % n];
            idx = (idx + 1) % n;
        } 
        else
        {
            std::lock_guard<std::mutex> lk(g_cfgMu);
            id = g_cfgItemId;
        }
        Il2CppString* itemStr = CreateMonoString(id.c_str());
        if (!itemStr) return;

        Il2CppObject* netObj = g_SpawnItem(itemStr, camPosition, rot, cb);
        if (!netObj) return;

        auto get_gameObject = (Il2CppObject*(*)(Il2CppObject*)) STRIP_FP(mComp_getGO->methodPointer);
        Il2CppObject* go = get_gameObject(netObj);
        if (!go || !grItemType) return;

        Il2CppObject* grComp = GO_GetComponentInChildren ? GO_GetComponentInChildren(go, grItemType) : nullptr;
        if (!grComp) return;

        uint8_t hueB;
        int8_t  satSb;
        if (g_cfgRandomColor.load())
        {
            hueB = (uint8_t)arc4random_uniform(256);
            int satRand = (int)arc4random_uniform(256) - 128;
            satSb = (int8_t)std::max(-128, std::min(127, satRand));
        } 
        else 
        {
            hueB = clamp_u8((float)g_cfgHue.load());
            satSb = clamp_i8((float)g_cfgSat.load());
        }
        int8_t scaleB = clamp_i8((float)g_cfgScale.load());

        ((void(*)(Il2CppObject*, int8_t )) STRIP_FP(mSetScale->methodPointer))(grComp, scaleB);
        ((void(*)(Il2CppObject*, int8_t )) STRIP_FP(mSetSat  ->methodPointer))(grComp, satSb);
        ((void(*)(Il2CppObject*, uint8_t)) STRIP_FP(mSetHue  ->methodPointer))(grComp, hueB);
        if(g_cfgItemSpamJiggle.load())
        {
            ((void(*)(Il2CppObject*, uint8_t)) STRIP_FP(mSetJelly  ->methodPointer))(grComp, 255);
        }
}
static void SetEquippingConfig(Il2CppObject* gobg)
{
    if (!GameObject || !GrabbableObject || !GameplayItemEquippingConfig ||
        !s_get_method_from_name || !s_class_get_field_from_name || !s_field_get_value || !s_runtime_invoke)
    {
        NSLog(@"[Kitty] PatchAllEquippingConfigs: missing il2cpp symbols/clses");
        return;
    }

    FieldInfo* f_equipping = s_class_get_field_from_name(GrabbableObject, "equippingConfig");
    if (!f_equipping) {
        NSLog(@"[Kitty] GrabbableObject.equippingConfig field not found");
        return;
    }

    static MethodInfo* m_isQuiver            = nullptr;
    static MethodInfo* m_isGrenadeLauncher   = nullptr;
    static MethodInfo* m_set_allowAddToQuiver   = nullptr;
    static MethodInfo* m_set_allowAddToGrenade  = nullptr;
    static MethodInfo* m_set_allowAttachToItem  = nullptr;
    static MethodInfo* m_set_allowAddToBag      = nullptr;
    static MethodInfo* m_set_allowAttachToBack  = nullptr;
    static MethodInfo* m_set_baseCapacity       = nullptr;
    static MethodInfo* m_set_detachChildrenDrop = nullptr;
    static MethodInfo* m_set_preventSaving      = nullptr;
    static MethodInfo* m_set_allowAttachToHip   = nullptr;

    if (!m_set_allowAddToQuiver) 
    {
        m_isQuiver            = s_get_method_from_name(GameplayItemEquippingConfig, "isQuiver", 0);
        m_isGrenadeLauncher   = s_get_method_from_name(GameplayItemEquippingConfig, "isGrenadeLauncher", 0);
        m_set_allowAddToQuiver   = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToQuiver",             1);
        m_set_allowAddToGrenade  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToGrenadeLauncher",    1);
        m_set_allowAttachToItem  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToItem",           1);
        m_set_allowAddToBag      = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToBag",               1);
        m_set_allowAttachToBack  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToBack",           1);
        m_set_baseCapacity       = s_get_method_from_name(GameplayItemEquippingConfig, "set_baseCapacity",                1);
        m_set_detachChildrenDrop = s_get_method_from_name(GameplayItemEquippingConfig, "set_detachChildrenWhenDropped",   1);
        m_set_preventSaving      = s_get_method_from_name(GameplayItemEquippingConfig, "set_preventSaving",               1);
        m_set_allowAttachToHip   = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToHip",            1);
    }

        Il2CppObject* gob = gobg;

        Il2CppObject* eqCfg = nullptr;
        s_field_get_value(gob, f_equipping, &eqCfg);

        bool isQuiver = false;
        bool isGrenade = false;

        if (m_isQuiver && m_isQuiver->methodPointer) 
        {
            isQuiver = ((bool(*)(Il2CppObject*))STRIP_FP(m_isQuiver->methodPointer))(eqCfg);
        }
        if (m_isGrenadeLauncher && m_isGrenadeLauncher->methodPointer) 
        {
            isGrenade = ((bool(*)(Il2CppObject*))STRIP_FP(m_isGrenadeLauncher->methodPointer))(eqCfg);
        }
        if (m_set_allowAddToQuiver && m_set_allowAddToQuiver->methodPointer && !isQuiver)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToQuiver->methodPointer))(eqCfg, true);
        }

        if (m_set_allowAddToGrenade && m_set_allowAddToGrenade->methodPointer && !isGrenade)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToGrenade->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAttachToItem && m_set_allowAttachToItem->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToItem->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAddToBag && m_set_allowAddToBag->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToBag->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAttachToBack && m_set_allowAttachToBack->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToBack->methodPointer))(eqCfg, true);
        }
        if (m_set_baseCapacity && m_set_baseCapacity->methodPointer)
        {
            ((void(*)(Il2CppObject*, int32_t))STRIP_FP(m_set_baseCapacity->methodPointer))(eqCfg, 999);
        }
        if (m_set_detachChildrenDrop && m_set_detachChildrenDrop->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_detachChildrenDrop->methodPointer))(eqCfg, false);
        }
        if (m_set_preventSaving && m_set_preventSaving->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_preventSaving->methodPointer))(eqCfg, false);
        }
        if (m_set_allowAttachToHip && m_set_allowAttachToHip->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToHip->methodPointer))(eqCfg, true);
        }

    NSLog(@"[Kitty] PatchAllEquippingConfigs done");
}
static void PatchAllEquippingConfigs()
{
    if (!GameObject || !GrabbableObject || !GameplayItemEquippingConfig ||
        !s_get_method_from_name || !s_class_get_field_from_name || !s_field_get_value || !s_runtime_invoke)
    {
        NSLog(@"[Kitty] PatchAllEquippingConfigs: missing il2cpp symbols/classes");
        return;
    }

    static MethodInfo* m_Find = nullptr;
    if (!m_Find) {
        m_Find = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_Find || !m_Find->methodPointer) {
            NSLog(@"[Kitty] GameObject.FindObjectsOfType(Type) not found");
            return;
        }
    }

    void* argsFO[1] = { TypeOf(GrabbableObject) };
    Il2CppException* ex = nullptr;
    Il2CppObject* arrObj = s_runtime_invoke(m_Find, nullptr, argsFO, &ex);
    if (ex || !arrObj) {
        NSLog(@"[Kitty] FindObjectsOfType(GrabbableObject) failed");
        return;
    }

    Il2CppArray* arr = (Il2CppArray*)arrObj;
    if (!arr || arr->max_length == 0) {
        NSLog(@"[Kitty] no GrabbableObject found");
        return;
    }

    FieldInfo* f_equipping = s_class_get_field_from_name(GrabbableObject, "equippingConfig");
    if (!f_equipping) {
        NSLog(@"[Kitty] GrabbableObject.equippingConfig field not found");
        return;
    }

    static MethodInfo* m_isQuiver            = nullptr;
    static MethodInfo* m_isGrenadeLauncher   = nullptr;
    static MethodInfo* m_set_allowAddToQuiver   = nullptr;
    static MethodInfo* m_set_allowAddToGrenade  = nullptr;
    static MethodInfo* m_set_allowAttachToItem  = nullptr;
    static MethodInfo* m_set_allowAddToBag      = nullptr;
    static MethodInfo* m_set_allowAttachToBack  = nullptr;
    static MethodInfo* m_set_baseCapacity       = nullptr;
    static MethodInfo* m_set_detachChildrenDrop = nullptr;
    static MethodInfo* m_set_preventSaving      = nullptr;
    static MethodInfo* m_set_allowAttachToHip   = nullptr;

    if (!m_set_allowAddToQuiver) 
    {
        m_isQuiver            = s_get_method_from_name(GameplayItemEquippingConfig, "isQuiver", 0);
        m_isGrenadeLauncher   = s_get_method_from_name(GameplayItemEquippingConfig, "isGrenadeLauncher", 0);
        m_set_allowAddToQuiver   = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToQuiver",             1);
        m_set_allowAddToGrenade  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToGrenadeLauncher",    1);
        m_set_allowAttachToItem  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToItem",           1);
        m_set_allowAddToBag      = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAddToBag",               1);
        m_set_allowAttachToBack  = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToBack",           1);
        m_set_baseCapacity       = s_get_method_from_name(GameplayItemEquippingConfig, "set_baseCapacity",                1);
        m_set_detachChildrenDrop = s_get_method_from_name(GameplayItemEquippingConfig, "set_detachChildrenWhenDropped",   1);
        m_set_preventSaving      = s_get_method_from_name(GameplayItemEquippingConfig, "set_preventSaving",               1);
        m_set_allowAttachToHip   = s_get_method_from_name(GameplayItemEquippingConfig, "set_allowAttachToHip",            1);
    }

    Il2CppObject** objs = (Il2CppObject**)((char*)arr + sizeof(Il2CppArray));

    for (il2cpp_array_size_t i = 0; i < arr->max_length; ++i) 
    {
        Il2CppObject* gob = objs[i];
        if (!gob) continue;

        Il2CppObject* eqCfg = nullptr;
        s_field_get_value(gob, f_equipping, &eqCfg);
        if (!eqCfg) continue;

        bool isQuiver = false;
        bool isGrenade = false;

        if (m_isQuiver && m_isQuiver->methodPointer) 
        {
            isQuiver = ((bool(*)(Il2CppObject*))STRIP_FP(m_isQuiver->methodPointer))(eqCfg);
        }
        if (m_isGrenadeLauncher && m_isGrenadeLauncher->methodPointer) 
        {
            isGrenade = ((bool(*)(Il2CppObject*))STRIP_FP(m_isGrenadeLauncher->methodPointer))(eqCfg);
        }
        if (m_set_allowAddToQuiver && m_set_allowAddToQuiver->methodPointer && !isQuiver)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToQuiver->methodPointer))(eqCfg, true);
        }

        if (m_set_allowAddToGrenade && m_set_allowAddToGrenade->methodPointer && !isGrenade)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToGrenade->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAttachToItem && m_set_allowAttachToItem->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToItem->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAddToBag && m_set_allowAddToBag->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAddToBag->methodPointer))(eqCfg, true);
        }
        if (m_set_allowAttachToBack && m_set_allowAttachToBack->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToBack->methodPointer))(eqCfg, true);
        }
        if (m_set_baseCapacity && m_set_baseCapacity->methodPointer)
        {
            ((void(*)(Il2CppObject*, int32_t))STRIP_FP(m_set_baseCapacity->methodPointer))(eqCfg, 999);
        }
        if (m_set_detachChildrenDrop && m_set_detachChildrenDrop->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_detachChildrenDrop->methodPointer))(eqCfg, false);
        }
        if (m_set_preventSaving && m_set_preventSaving->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_preventSaving->methodPointer))(eqCfg, false);
        }
        if (m_set_allowAttachToHip && m_set_allowAttachToHip->methodPointer)
        {
            ((void(*)(Il2CppObject*, bool))STRIP_FP(m_set_allowAttachToHip->methodPointer))(eqCfg, true);
        }
    }

    NSLog(@"[Kitty] PatchAllEquippingConfigs done");
}
static void SetQuiverState(Il2CppObject* quiverInstance, int newState)
{
    if (!quiverInstance || !Quiver) {
        NSLog(@"[Kitty] InitializeQuiverState: no quiver / class");
        return;
    }

    static MethodInfo* m_getContained = nullptr;
    if (!m_getContained) {
        m_getContained = s_get_method_from_name(Quiver, "get_containedObjects", 0);
        if (!m_getContained || !m_getContained->methodPointer) {
            NSLog(@"[Kitty] InitializeQuiverState: get_containedObjects not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getContained, quiverInstance, nullptr, &ex);
    if (ex || !boxedList) {
        NSLog(@"[Kitty] InitializeQuiverState: get_containedObjects failed ex=%p list=%p", ex, boxedList);
        return;
    }

    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    static MethodInfo* m_getCount = nullptr;
    static MethodInfo* m_getItem  = nullptr;
    static MethodInfo* m_setItem  = nullptr;

    if (!m_getCount || !m_getItem || !m_setItem) {
        Il2CppClass* listClass = s_object_get_class(boxedList);
        if (!listClass) {
            NSLog(@"[Kitty] InitializeQuiverState: listClass NULL");
            return;
        }

        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        m_getItem  = s_get_method_from_name(listClass, "get_Item", 1);
        m_setItem  = s_get_method_from_name(listClass, "Set",      2);
        if (!m_setItem)
            m_setItem = s_get_method_from_name(listClass, "set_Item", 2);

        if (!m_getCount || !m_getItem || !m_setItem ||
            !m_getCount->methodPointer || !m_getItem->methodPointer || !m_setItem->methodPointer)
        {
            NSLog(@"[Kitty] InitializeQuiverState: list methods missing");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* boxedCount = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
    if (ex || !boxedCount) {
        NSLog(@"[Kitty] InitializeQuiverState: get_Count failed ex=%p countObj=%p", ex, boxedCount);
        return;
    }

    int count = *(int*)((char*)boxedCount + sizeof(Il2CppObject));
    if (count <= 0) {
        NSLog(@"[Kitty] InitializeQuiverState: list empty (count=%d)", count);
        return;
    }

    NSLog(@"[Kitty] InitializeQuiverState: count=%d, newState=%d", count, newState);

    for (int i = 0; i < count; ++i) 
    {
        void* argsIdx[1] = { &i };
        ex = nullptr;
        Il2CppObject* boxedElem = s_runtime_invoke(m_getItem, listThis, argsIdx, &ex);
        if (ex || !boxedElem) {
            NSLog(@"[Kitty] InitializeQuiverState: get_Item(%d) failed ex=%p elem=%p", i, ex, boxedElem);
            continue;
        }

        char* elemValPtr = (char*)boxedElem + sizeof(Il2CppObject);

        uint8_t buf[kContainedItemCoreDataSize];
        memcpy(buf, elemValPtr, kContainedItemCoreDataSize);

        int* statePtr = (int*)(buf + 0x08);
        *statePtr = newState;

        void* argsSet[2] = { &i, buf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, listThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] InitializeQuiverState: Set[%d] threw ex=%p", i, ex);
            continue;
        }

        NSLog(@"[Kitty] InitializeQuiverState: slot %d state set to %d", i, *statePtr);
    }

    NSLog(@"[Kitty] InitializeQuiverState: done");
}
static void SetQuiverAmmo(Il2CppObject* quiverInstance, int newAmmo)
{
    if (!quiverInstance || !Quiver) {
        NSLog(@"[Kitty] InitializeQuiverAmmo: no quiver / class");
        return;
    }

    static MethodInfo* m_getContained = nullptr;
    if (!m_getContained) 
    {
        m_getContained = s_get_method_from_name(Quiver, "get_containedObjects", 0);
        if (!m_getContained || !m_getContained->methodPointer) {
            NSLog(@"[Kitty] InitializeQuiverAmmo: get_containedObjects not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getContained, quiverInstance, nullptr, &ex);
    if (ex || !boxedList) 
    {
        NSLog(@"[Kitty] InitializeQuiverAmmo: get_containedObjects failed ex=%p list=%p", ex, boxedList);
        return;
    }

    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    static MethodInfo* m_getCount = nullptr;
    static MethodInfo* m_getItem  = nullptr;
    static MethodInfo* m_setItem  = nullptr;

    if (!m_getCount || !m_getItem || !m_setItem) {
        Il2CppClass* listClass = s_object_get_class(boxedList);
        if (!listClass) {
            NSLog(@"[Kitty] InitializeQuiverAmmo: listClass NULL");
            return;
        }

        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        m_getItem  = s_get_method_from_name(listClass, "get_Item", 1);
        m_setItem  = s_get_method_from_name(listClass, "Set",      2);
        if (!m_setItem)
            m_setItem = s_get_method_from_name(listClass, "set_Item", 2);

        if (!m_getCount || !m_getItem || !m_setItem ||
            !m_getCount->methodPointer || !m_getItem->methodPointer || !m_setItem->methodPointer)
        {
            NSLog(@"[Kitty] InitializeQuiverAmmo: list methods missing");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* boxedCount = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
    if (ex || !boxedCount) {
        NSLog(@"[Kitty] InitializeQuiverAmmo: get_Count failed ex=%p countObj=%p", ex, boxedCount);
        return;
    }

    int count = *(int*)((char*)boxedCount + sizeof(Il2CppObject));
    if (count <= 0) {
        NSLog(@"[Kitty] InitializeQuiverAmmo: list empty (count=%d)", count);
        return;
    }

    NSLog(@"[Kitty] InitializeQuiverAmmo: count=%d, newAmmo=%d", count, newAmmo);

    for (int i = 0; i < count; ++i) {
        void* argsIdx[1] = { &i };
        ex = nullptr;
        Il2CppObject* boxedElem = s_runtime_invoke(m_getItem, listThis, argsIdx, &ex);
        if (ex || !boxedElem) {
            NSLog(@"[Kitty] InitializeQuiverAmmo: get_Item(%d) failed ex=%p elem=%p", i, ex, boxedElem);
            continue;
        }

        char* elemValPtr = (char*)boxedElem + sizeof(Il2CppObject);
        uint8_t buf[kContainedItemCoreDataSize];
        memcpy(buf, elemValPtr, kContainedItemCoreDataSize);
        int* ammoPtr = (int*)(buf + 0x0C);
        *ammoPtr = newAmmo;

        void* argsSet[2] = { &i, buf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, listThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] InitializeQuiverAmmo: Set[%d] threw ex=%p", i, ex);
            continue;
        }

        NSLog(@"[Kitty] InitializeQuiverAmmo: slot %d ammo set to %d", i, *ammoPtr);
    }

    NSLog(@"[Kitty] InitializeQuiverAmmo: done");
}
static void SetQuiverNetId(Il2CppObject* quiverInstance, short newNetId)
{
    if (!quiverInstance || !Quiver) {
        NSLog(@"[Kitty] InitializeQuiverNetId: no quiver / class");
        return;
    }

    static MethodInfo* m_getContained = nullptr;
    if (!m_getContained) {
        m_getContained = s_get_method_from_name(Quiver, "get_containedObjects", 0);
        if (!m_getContained || !m_getContained->methodPointer) {
            NSLog(@"[Kitty] InitializeQuiverNetId: get_containedObjects not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getContained, quiverInstance, nullptr, &ex);
    if (ex || !boxedList) {
        NSLog(@"[Kitty] InitializeQuiverNetId: get_containedObjects failed ex=%p list=%p", ex, boxedList);
        return;
    }

    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    static MethodInfo* m_getCount = nullptr;
    static MethodInfo* m_getItem  = nullptr;
    static MethodInfo* m_setItem  = nullptr;

    if (!m_getCount || !m_getItem || !m_setItem) {
        Il2CppClass* listClass = s_object_get_class(boxedList);
        if (!listClass) {
            NSLog(@"[Kitty] InitializeQuiverNetId: listClass NULL");
            return;
        }

        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        m_getItem  = s_get_method_from_name(listClass, "get_Item", 1);
        m_setItem  = s_get_method_from_name(listClass, "Set",      2);
        if (!m_setItem)
            m_setItem = s_get_method_from_name(listClass, "set_Item", 2);

        if (!m_getCount || !m_getItem || !m_setItem ||
            !m_getCount->methodPointer || !m_getItem->methodPointer || !m_setItem->methodPointer)
        {
            NSLog(@"[Kitty] InitializeQuiverNetId: list methods missing");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* boxedCount = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
    if (ex || !boxedCount) {
        NSLog(@"[Kitty] InitializeQuiverNetId: get_Count failed ex=%p countObj=%p", ex, boxedCount);
        return;
    }

    int count = *(int*)((char*)boxedCount + sizeof(Il2CppObject));
    if (count <= 0) {
        NSLog(@"[Kitty] InitializeQuiverNetId: list empty (count=%d)", count);
        return;
    }

    NSLog(@"[Kitty] InitializeQuiverNetId: count=%d, newNetId=%d", count, (int)newNetId);

    for (int i = 0; i < count; ++i) {
        void* argsIdx[1] = { &i };
        ex = nullptr;
        Il2CppObject* boxedElem = s_runtime_invoke(m_getItem, listThis, argsIdx, &ex);
        if (ex || !boxedElem) {
            NSLog(@"[Kitty] InitializeQuiverNetId: get_Item(%d) failed ex=%p elem=%p", i, ex, boxedElem);
            continue;
        }

        char* elemValPtr = (char*)boxedElem + sizeof(Il2CppObject);

        uint8_t buf[kContainedItemCoreDataSize];
        memcpy(buf, elemValPtr, kContainedItemCoreDataSize);

        short* netIdPtr = (short*)(buf + 0x04);
        *netIdPtr = newNetId;

        void* argsSet[2] = { &i, buf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, listThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] InitializeQuiverNetId: Set[%d] threw ex=%p", i, ex);
            continue;
        }

        NSLog(@"[Kitty] InitializeQuiverNetId: slot %d netID set to %d", i, (int)*netIdPtr);
    }

    NSLog(@"[Kitty] InitializeQuiverNetId: done");
}
static void SetQuiverItemId(Il2CppObject* quiverInstance, short newId)
{
    if (!quiverInstance || !Quiver) {
        NSLog(@"[Kitty] InitializeQuiverItemId: no quiver / class");
        return;
    }

    static MethodInfo* m_getContained = nullptr;
    if (!m_getContained) {
        m_getContained = s_get_method_from_name(Quiver, "get_containedObjects", 0);
        if (!m_getContained || !m_getContained->methodPointer) {
            NSLog(@"[Kitty] InitializeQuiverItemId: get_containedObjects not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getContained, quiverInstance, nullptr, &ex);
    if (ex || !boxedList) {
        NSLog(@"[Kitty] InitializeQuiverItemId: get_containedObjects failed ex=%p list=%p", ex, boxedList);
        return;
    }

    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    static MethodInfo* m_getCount = nullptr;
    static MethodInfo* m_getItem  = nullptr;
    static MethodInfo* m_setItem  = nullptr;

    if (!m_getCount || !m_getItem || !m_setItem) {
        Il2CppClass* listClass = s_object_get_class(boxedList);
        if (!listClass) {
            NSLog(@"[Kitty] InitializeQuiverItemId: listClass NULL");
            return;
        }

        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        m_getItem  = s_get_method_from_name(listClass, "get_Item", 1);
        m_setItem  = s_get_method_from_name(listClass, "Set",      2);
        if (!m_setItem)
            m_setItem = s_get_method_from_name(listClass, "set_Item", 2);

        if (!m_getCount || !m_getItem || !m_setItem ||
            !m_getCount->methodPointer || !m_getItem->methodPointer || !m_setItem->methodPointer)
        {
            NSLog(@"[Kitty] InitializeQuiverItemId: list methods missing");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* boxedCount = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
    if (ex || !boxedCount) {
        NSLog(@"[Kitty] InitializeQuiverItemId: get_Count failed ex=%p countObj=%p", ex, boxedCount);
        return;
    }

    int count = *(int*)((char*)boxedCount + sizeof(Il2CppObject));
    if (count <= 0) {
        NSLog(@"[Kitty] InitializeQuiverItemId: list empty (count=%d)", count);
        return;
    }

    NSLog(@"[Kitty] InitializeQuiverItemId: count=%d, newId=%d", count, (int)newId);

    for (int i = 0; i < count; ++i) {
        void* argsIdx[1] = { &i };
        ex = nullptr;
        Il2CppObject* boxedElem = s_runtime_invoke(m_getItem, listThis, argsIdx, &ex);
        if (ex || !boxedElem) {
            NSLog(@"[Kitty] InitializeQuiverItemId: get_Item(%d) failed ex=%p elem=%p", i, ex, boxedElem);
            continue;
        }

        char* elemValPtr = (char*)boxedElem + sizeof(Il2CppObject);

        uint8_t buf[kContainedItemCoreDataSize];
        memcpy(buf, elemValPtr, kContainedItemCoreDataSize);

        short* idPtr = (short*)(buf + 0x00);
        *idPtr = newId;

        void* argsSet[2] = { &i, buf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, listThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] InitializeQuiverItemId: Set[%d] threw ex=%p", i, ex);
            continue;
        }

        NSLog(@"[Kitty] InitializeQuiverItemId: slot %d id set to %d", i, (int)*idPtr);
    }

    NSLog(@"[Kitty] InitializeQuiverItemId: done");
}
static void SetBackpackNetId(Il2CppObject* backpackInstance, short newNetId)
{
    if (!backpackInstance || !BackpackItem) {
        NSLog(@"[Kitty] SetBackpackNetId: no backpack / class");
        return;
    }

    // get allItems (NetworkDictionary<short, ContainedItem>)
    static MethodInfo* m_get_allItems = nullptr;
    if (!m_get_allItems) {
        m_get_allItems = s_get_method_from_name(BackpackItem, "get_allItems", 0);
        if (!m_get_allItems || !m_get_allItems->methodPointer) {
            NSLog(@"[Kitty] SetBackpackNetId: get_allItems not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedDict = s_runtime_invoke(m_get_allItems, backpackInstance, nullptr, &ex);
    if (ex || !boxedDict) {
        NSLog(@"[Kitty] SetBackpackNetId: get_allItems failed ex=%p dict=%p", ex, boxedDict);
        return;
    }

    void* dictThis = (void*)((char*)boxedDict + sizeof(Il2CppObject));
    Il2CppClass* dictClass = s_object_get_class(boxedDict);
    if (!dictClass) {
        NSLog(@"[Kitty] SetBackpackNetId: dictClass NULL");
        return;
    }

    static MethodInfo* m_GetEnumerator = nullptr;
    static MethodInfo* m_setItem      = nullptr;

    if (!m_GetEnumerator || !m_setItem) {
        m_GetEnumerator = s_get_method_from_name(dictClass, "GetEnumerator", 0);
        if (!m_GetEnumerator || !m_GetEnumerator->methodPointer) {
            NSLog(@"[Kitty] SetBackpackNetId: GetEnumerator not found");
            return;
        }

        // indexer setter: void set_Item(short key, ContainedItem value)
        m_setItem = s_get_method_from_name(dictClass, "set_Item", 2);
        if (!m_setItem || !m_setItem->methodPointer) {
            // some Fusion builds use "Set" internally
            m_setItem = s_get_method_from_name(dictClass, "Set", 2);
        }
        if (!m_setItem || !m_setItem->methodPointer) {
            NSLog(@"[Kitty] SetBackpackNetId: set_Item/Set not found");
            return;
        }
    }

    // Get enumerator
    ex = nullptr;
    Il2CppObject* boxedEnum = s_runtime_invoke(m_GetEnumerator, dictThis, nullptr, &ex);
    if (ex || !boxedEnum) {
        NSLog(@"[Kitty] SetBackpackNetId: GetEnumerator failed ex=%p enum=%p", ex, boxedEnum);
        return;
    }

    void* enumThis = (void*)((char*)boxedEnum + sizeof(Il2CppObject));
    Il2CppClass* enumClass = s_object_get_class(boxedEnum);
    if (!enumClass) {
        NSLog(@"[Kitty] SetBackpackNetId: enumClass NULL");
        return;
    }

    static MethodInfo* m_MoveNext   = nullptr;
    static MethodInfo* m_getCurrent = nullptr;
    static FieldInfo*  f_kv_key     = nullptr;
    static FieldInfo*  f_kv_value   = nullptr;

    if (!m_MoveNext || !m_getCurrent) {
        m_MoveNext   = s_get_method_from_name(enumClass, "MoveNext", 0);
        m_getCurrent = s_get_method_from_name(enumClass, "get_Current", 0);

        if (!m_MoveNext || !m_MoveNext->methodPointer ||
            !m_getCurrent || !m_getCurrent->methodPointer) {
            NSLog(@"[Kitty] SetBackpackNetId: MoveNext/get_Current not found");
            return;
        }
    }

    int patchedCount = 0;

    while (true) {
        // MoveNext
        ex = nullptr;
        Il2CppObject* boxedHasMore = s_runtime_invoke(m_MoveNext, enumThis, nullptr, &ex);
        if (ex || !boxedHasMore) {
            NSLog(@"[Kitty] SetBackpackNetId: MoveNext failed ex=%p", ex);
            break;
        }

        bool hasMore = *(bool*)((char*)boxedHasMore + sizeof(Il2CppObject));
        if (!hasMore)
            break;

        // Current: KeyValuePair<short, ContainedItem>
        ex = nullptr;
        Il2CppObject* boxedKV = s_runtime_invoke(m_getCurrent, enumThis, nullptr, &ex);
        if (ex || !boxedKV) {
            NSLog(@"[Kitty] SetBackpackNetId: get_Current failed ex=%p kv=%p", ex, boxedKV);
            break;
        }

        Il2CppClass* kvClass = s_object_get_class(boxedKV);
        if (!kvClass) {
            NSLog(@"[Kitty] SetBackpackNetId: kvClass NULL");
            break;
        }

        if (!f_kv_key || !f_kv_value) {
            f_kv_key   = s_class_get_field_from_name(kvClass, "key");
            f_kv_value = s_class_get_field_from_name(kvClass, "value");
            if (!f_kv_key || !f_kv_value) {
                NSLog(@"[Kitty] SetBackpackNetId: key/value fields not found on KVP");
                break;
            }
        }

        short key = 0;
        uint8_t valueBuf[64] = {0}; // big enough for ContainedItem

        s_field_get_value(boxedKV, f_kv_key,   &key);
        s_field_get_value(boxedKV, f_kv_value, valueBuf);

        // patch netID inside ContainedItem.data
        short* netIdPtr = (short*)(valueBuf + kContainedItemNetIdOffset);
        *netIdPtr = newNetId;

        void* argsSet[2] = { &key, valueBuf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, dictThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] SetBackpackNetId: set_Item key=%d ex=%p", (int)key, ex);
            continue;
        }

        patchedCount++;
    }

    NSLog(@"[Kitty] SetBackpackNetId: patched %d entries to netID=%d",
          patchedCount, (int)newNetId);
}
static void SpamQuiverWithContents()
{
    if(g_cfgBackpackMode.load())
    {
        if (!PrefabGenerator || !GrabbableItem || !BackpackItem || !GameObject ||
        !g_SpawnItem || !GO_GetComponentInChildren || !s_get_method_from_name || !s_runtime_invoke)
        {
            NSLog(@"[Kitty] SpawnBanana: required il2cpp symbols/classes missing");
            return;
        }

        auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
        auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
        auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
        auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);

        Il2CppObject* grItemType = nullptr;
        if (s_type_get_object && GrabbableItem)
            grItemType = s_type_get_object(&GrabbableItem->byval_arg);

        std::vector<ChildSpec> children;
        {
            std::lock_guard<std::mutex> lk(g_cfgMd);
            children = g_cfgChildren;
        }

        Il2CppObject* backpackType    = TypeOf(BackpackItem);
        Il2CppObject* quiverType    = TypeOf(Quiver);
        Il2CppObject* grabbableType = TypeOf(GrabbableItem);

        auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
        if (!m_TryAddItem || !m_TryAddItem->methodPointer) {
            NSLog(@"[Kitty] SpawnBanana: BackpackItem.TryAddItem not found");
            return;
        }
        auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

        uint8_t hueB = clamp_u8((float)g_cfgQHue.load());
        int8_t satSb = clamp_i8((float)g_cfgQSat.load());
        int8_t scaleB = clamp_i8((float)g_cfgQScale.load());

        Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_backpack_large_basketball"), GetCamPosition(), (int8_t)scaleB, (int8_t)satSb, (uint8_t)hueB);
        if (!goQuiver) 
        {
            NSLog(@"[Kitty] SpawnBanana: failed to spawn quiver");
            return;
        }

        Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, backpackType);
        if (!quiver) 
        {
            NSLog(@"[Kitty] SpawnBanana: quiver not found on spawned object");
            return;
        }

        for (const ChildSpec& cs : children)
        {
            NSLog(@"[Kitty] child itemId=%s ammo=%d hue=%d sat=%d scale=%d", cs.itemId.c_str(), cs.ammo, cs.colorHue, cs.colorSat, cs.scale);

            if (cs.itemId.empty()) {
                continue;
            }

            std::string fullPath = cs.itemId;
            Il2CppString* prefabName = CreateMonoString(fullPath.c_str());

            Il2CppObject* goItem = nullptr;
            if(g_cfgContentsJiggle.load())
            {
                goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue, true);
            }
            else
            {
                goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue);
            }

            Il2CppObject* grabbable = GO_GetComponentInChildren(goItem, grabbableType);

            SetEquippingConfig(grabbable);

            bool ok = TryAddItem(quiver, grabbable);
            if(g_netId.load() != -1)
            {
                SetBackpackNetId(quiver, g_netId.load());
            }
            NSLog(@"[Kitty] CheckToAddItem -> %d for %s", (int)ok, fullPath.c_str());
        }
    }
    else
    {
     if (!PrefabGenerator || !GrabbableItem || !BackpackItem || !GameObject ||
        !g_SpawnItem || !GO_GetComponentInChildren || !s_get_method_from_name || !s_runtime_invoke)
        {
            NSLog(@"[Kitty] SpawnBanana: required il2cpp symbols/classes missing");
            return;
        }

        auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
        auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
        auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
        auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);

        Il2CppObject* grItemType = nullptr;
        if (s_type_get_object && GrabbableItem)
            grItemType = s_type_get_object(&GrabbableItem->byval_arg);

        std::vector<ChildSpec> children;
        {
            std::lock_guard<std::mutex> lk(g_cfgMd);
            children = g_cfgChildren;
        }

        Il2CppObject* quiverType    = TypeOf(Quiver);
        Il2CppObject* grabbableType = TypeOf(GrabbableItem);

        auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
        if (!m_TryAddItem || !m_TryAddItem->methodPointer) {
            NSLog(@"[Kitty] SpawnBanana: BackpackItem.TryAddItem not found");
            return;
        }
        auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

        uint8_t hueB = clamp_u8((float)g_cfgQHue.load());
        int8_t satSb = clamp_i8((float)g_cfgQSat.load());
        int8_t scaleB = clamp_i8((float)g_cfgQScale.load());

        Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_quiver"), GetCamPosition(), (int8_t)scaleB, (int8_t)satSb, (uint8_t)hueB);
        if (!goQuiver) 
        {
            NSLog(@"[Kitty] SpawnBanana: failed to spawn quiver");
            return;
        }

        Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, quiverType);
        if (!quiver) 
        {
            NSLog(@"[Kitty] SpawnBanana: quiver not found on spawned object");
            return;
        }

        for (const ChildSpec& cs : children)
        {
            NSLog(@"[Kitty] child itemId=%s ammo=%d hue=%d sat=%d scale=%d", cs.itemId.c_str(), cs.ammo, cs.colorHue, cs.colorSat, cs.scale);

            if (cs.itemId.empty()) {
                continue;
            }

            std::string fullPath = cs.itemId;
            Il2CppString* prefabName = CreateMonoString(fullPath.c_str());

            Il2CppObject* goItem = nullptr;
            if(g_cfgContentsJiggle.load())
            {
                goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue, true);
            }
            else
            {
                goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue);
            }

            Il2CppObject* grabbable = GO_GetComponentInChildren(goItem, grabbableType);

            SetEquippingConfig(grabbable);

            bool ok = TryAddItem(quiver, grabbable);
            if(cs.itemId == "item_shredder")
            {
                SetQuiverState(quiver, 800000);
            }
            if(g_netId.load() != -1)
            {
                SetQuiverNetId(quiver, g_netId.load());
            }
            NSLog(@"[Kitty] CheckToAddItem -> %d for %s", (int)ok, fullPath.c_str());
        }
    }
}
static void SpawnQuiverWithContents()
{
    if(g_cfgBackpackMode.load())
    {
        if(!quiverDone)
        {
            if (!PrefabGenerator || !GrabbableItem || !BackpackItem || !GameObject ||
            !g_SpawnItem || !GO_GetComponentInChildren || !s_get_method_from_name || !s_runtime_invoke)
            {
                NSLog(@"[Kitty] SpawnBanana: required il2cpp symbols/classes missing");
                return;
            }

            auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
            auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
            auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
            auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);

            Il2CppObject* grItemType = nullptr;
            if (s_type_get_object && GrabbableItem)
                grItemType = s_type_get_object(&GrabbableItem->byval_arg);

            std::vector<ChildSpec> children;
            {
                std::lock_guard<std::mutex> lk(g_cfgMd);
                children = g_cfgChildren;
            }

            Il2CppObject* backpackType    = TypeOf(BackpackItem);
            Il2CppObject* quiverType    = TypeOf(Quiver);
            Il2CppObject* grabbableType = TypeOf(GrabbableItem);

            auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
            if (!m_TryAddItem || !m_TryAddItem->methodPointer) {
                NSLog(@"[Kitty] SpawnBanana: BackpackItem.TryAddItem not found");
                return;
            }
            auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

            auto m_set_capac = s_get_method_from_name(BackpackItem, "set_capacity", 1);
            auto Set_Capacity = (uint8_t(*)(Il2CppObject*, uint8_t))STRIP_FP(m_set_capac->methodPointer);

            uint8_t hueB = clamp_u8((float)g_cfgQHue.load());
            int8_t satSb = clamp_i8((float)g_cfgQSat.load());
            int8_t scaleB = clamp_i8((float)g_cfgQScale.load());

            Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_backpack_small_base"), GetCamPosition(), (int8_t)scaleB, (int8_t)satSb, (uint8_t)hueB);
            if (!goQuiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: failed to spawn quiver");
                return;
            }

            Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, backpackType);
            if (!quiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: quiver not found on spawned object");
                return;
            }

            Set_Capacity(quiver, 255);

            for (const ChildSpec& cs : children)
            {
                NSLog(@"[Kitty] child itemId=%s ammo=%d hue=%d sat=%d scale=%d", cs.itemId.c_str(), cs.ammo, cs.colorHue, cs.colorSat, cs.scale);

                if (cs.itemId.empty()) {
                    continue;
                }

                std::string fullPath = cs.itemId;
                Il2CppString* prefabName = CreateMonoString(fullPath.c_str());

                Il2CppObject* goItem = nullptr;
                if(g_cfgContentsJiggle.load())
                {
                    goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue, true);
                }
                else
                {
                    goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue);
                }

                Il2CppObject* grabbable = GO_GetComponentInChildren(goItem, grabbableType);

                SetEquippingConfig(grabbable);

                bool ok = TryAddItem(quiver, grabbable);

                if(g_netId.load() != -1)
                {
                    SetBackpackNetId(quiver, g_netId.load());
                }
                NSLog(@"[Kitty] CheckToAddItem -> %d for %s", (int)ok, fullPath.c_str());
            }
            quiverDone = true;
        }

    }
    else
    {
        if(!quiverDone)
        {
            if (!PrefabGenerator || !GrabbableItem || !BackpackItem || !GameObject ||
            !g_SpawnItem || !GO_GetComponentInChildren || !s_get_method_from_name || !s_runtime_invoke)
            {
                NSLog(@"[Kitty] SpawnBanana: required il2cpp symbols/classes missing");
                return;
            }

            auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
            auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
            auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
            auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);

            Il2CppObject* grItemType = nullptr;
            if (s_type_get_object && GrabbableItem)
                grItemType = s_type_get_object(&GrabbableItem->byval_arg);

            std::vector<ChildSpec> children;
            {
                std::lock_guard<std::mutex> lk(g_cfgMd);
                children = g_cfgChildren;
            }

            Il2CppObject* backpackType    = TypeOf(BackpackItem);
            Il2CppObject* quiverType    = TypeOf(Quiver);
            Il2CppObject* grabbableType = TypeOf(GrabbableItem);

            auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
            if (!m_TryAddItem || !m_TryAddItem->methodPointer) {
                NSLog(@"[Kitty] SpawnBanana: BackpackItem.TryAddItem not found");
                return;
            }
            auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

            uint8_t hueB = clamp_u8((float)g_cfgQHue.load());
            int8_t satSb = clamp_i8((float)g_cfgQSat.load());
            int8_t scaleB = clamp_i8((float)g_cfgQScale.load());

            Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_quiver"), GetCamPosition(), (int8_t)scaleB, (int8_t)satSb, (uint8_t)hueB);
            if (!goQuiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: failed to spawn quiver");
                return;
            }

            Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, quiverType);
            if (!quiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: quiver not found on spawned object");
                return;
            }

            for (const ChildSpec& cs : children)
            {
                NSLog(@"[Kitty] child itemId=%s ammo=%d hue=%d sat=%d scale=%d", cs.itemId.c_str(), cs.ammo, cs.colorHue, cs.colorSat, cs.scale);

                if (cs.itemId.empty()) {
                    continue;
                }

                std::string fullPath = cs.itemId;
                Il2CppString* prefabName = CreateMonoString(fullPath.c_str());

                Il2CppObject* goItem = nullptr;
                if(g_cfgContentsJiggle.load())
                {
                    goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue, true);
                }
                else
                {
                    goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue);
                }
                Il2CppObject* grabbable = GO_GetComponentInChildren(goItem, grabbableType);

                SetEquippingConfig(grabbable);

                bool ok = TryAddItem(quiver, grabbable);

                if(cs.ammo == 1)
                {
                    SetQuiverAmmo(quiver, 1);
                }
                if(cs.itemId == "item_shredder")
                {
                    SetQuiverState(quiver, 2147483647);
                }
                if(g_netId.load() != -1)
                {
                    SetQuiverNetId(quiver, g_netId.load());
                }
                NSLog(@"[Kitty] CheckToAddItem -> %d for %s", (int)ok, fullPath.c_str());
            }
            quiverDone = true;
        }
    }
}
static void SpawnQuiverAndSetGrabPos()
{
    if (!Quiver || !s_get_method_from_name || !s_runtime_invoke || !s_object_get_class) {
        NSLog(@"[GrabPos] missing symbols/classes");
        return;
    }

    Il2CppObject* go = SpawnItem(CreateMonoString("item_quiver"), GetCamPosition(), (int8_t)127, (int8_t)0, (uint8_t)0);
    if (!go) { NSLog(@"[GrabPos] SpawnItem failed"); return; }

    Il2CppObject* quiver = GO_GetComponentInChildren(go, TypeOf(Quiver));
    if (!quiver) { NSLog(@"[GrabPos] quiver component not found"); return; }

    Il2CppObject* tempRoot = *(Il2CppObject**)((char*)quiver + kQuiver_TempItemState_Offset);
    if (!tempRoot) { NSLog(@"[GrabPos] _tempItemState null"); return; }
    NSLog(@"[GrabPos] TempStateRoot=%p", tempRoot);

    Il2CppClass* tsrCls = s_object_get_class(tempRoot);
    MethodInfo* m_get_state = s_get_method_from_name(tsrCls, "get_state", 0);
    if (!m_get_state || !m_get_state->methodPointer) { NSLog(@"[GrabPos] get_state missing"); return; }

    Il2CppException* ex = nullptr;
    Il2CppObject* itemState = s_runtime_invoke(m_get_state, tempRoot, nullptr, &ex);
    if (ex || !itemState) { NSLog(@"[GrabPos] get_state ex=%p state=%p", ex, itemState); return; }
    NSLog(@"[GrabPos] GrabbableItemState=%p", itemState);

    Il2CppClass* gisCls = s_object_get_class(itemState);
    MethodInfo* m_get_grabPos = s_get_method_from_name(gisCls, "get_grabInfoPosition", 0);
    if (!m_get_grabPos || !m_get_grabPos->methodPointer) { NSLog(@"[GrabPos] get_grabInfoPosition missing"); return; }

    ex = nullptr;
    Il2CppObject* posSP = s_runtime_invoke(m_get_grabPos, itemState, nullptr, &ex);
    if (ex || !posSP) { NSLog(@"[GrabPos] get_grabInfoPosition ex=%p sp=%p", ex, posSP); return; }
    NSLog(@"[GrabPos] StatePrimitive<Vector3>=%p", posSP);

    Il2CppClass* spCls = s_object_get_class(posSP);
    MethodInfo* m_set_value = s_get_method_from_name(spCls, "set_value", 1);
    MethodInfo* m_SetValue  = m_set_value ? nullptr : s_get_method_from_name(spCls, "SetValue", 1);
    if ((!m_set_value || !m_set_value->methodPointer) && (!m_SetValue || !m_SetValue->methodPointer)) {
        NSLog(@"[GrabPos] no setter on StatePrimitive<Vector3>");
        return;
    }

    struct Vec3 { float x,y,z; };
    Vec3 v{0.f, 9.f, 0.f};

    if (m_set_value && m_set_value->methodPointer) 
    {
        void* args[1] = { &v };
        ex = nullptr;
        s_runtime_invoke(m_set_value, posSP, args, &ex);
        if (ex) { NSLog(@"[GrabPos] set_value ex=%p", ex); return; }
        NSLog(@"[GrabPos] set via set_value -> (0,9,0)");
    } 
    else 
    {
        void* args[1] = { &v };
        ex = nullptr;
        s_runtime_invoke(m_SetValue, posSP, args, &ex);
        if (ex) { NSLog(@"[GrabPos] SetValue ex=%p", ex); return; }
        NSLog(@"[GrabPos] set via SetValue -> (0,9,0)");
    }
}
static void SendNetPlayersToAPI()
{
    if (!GameObject || !NetPlayer || !s_get_method_from_name || !s_runtime_invoke) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: missing il2cpp symbols/classes");
        return;
    }
    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] SendNetPlayersToAPI: FindObjectsOfType(Type) not found");
            return;
        }
    }

    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    if (!typeNetPlayer) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: TypeOf(NetPlayer) failed");
        return;
    }

    Il2CppException* ex = nullptr;
    void* argsFO[1] = { typeNetPlayer };
    Il2CppObject* arrObj = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFO, &ex);
    if (ex || !arrObj) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: FindObjectsOfType failed ex=%p arr=%p", ex, arrObj);
        return;
    }

    Il2CppArray* arr = (Il2CppArray*)arrObj;
    if (!arr || arr->max_length == 0) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: no NetPlayer instances");
        return;
    }

    static MethodInfo* m_getDisplayName = nullptr;
    if (!m_getDisplayName) {
        m_getDisplayName = s_get_method_from_name(NetPlayer, "get_displayName", 0);
        if (!m_getDisplayName || !m_getDisplayName->methodPointer) {
            NSLog(@"[Kitty] SendNetPlayersToAPI: get_displayName not found");
            return;
        }
    }

    std::vector<std::string> names;
    names.reserve(arr->max_length);

    Il2CppObject** elems = (Il2CppObject**)((char*)arr + sizeof(Il2CppArray));
    for (il2cpp_array_size_t i = 0; i < arr->max_length; ++i) {
        Il2CppObject* np = elems[i];
        if (!np) continue;

        ex = nullptr;
        Il2CppObject* nameObj = s_runtime_invoke(m_getDisplayName, np, nullptr, &ex);
        if (ex || !nameObj) {
            NSLog(@"[Kitty] get_displayName failed idx=%u ex=%p obj=%p",
                  (unsigned)i, ex, nameObj);
            continue;
        }

        Il2CppString* il2Name = (Il2CppString*)nameObj;
        std::string name = il2cpp_string_to_std(il2Name, string_chars, string_length);
        if (!name.empty())
            names.push_back(name);
    }

    if (names.empty()) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: no display names collected");
        return;
    }

    NSLog(@"[Kitty] SendNetPlayersToAPI: collected %u player(s)", (unsigned)names.size());

    NSMutableArray<NSString*> *playerList = [NSMutableArray arrayWithCapacity:names.size()];
    for (auto &n : names) {
        [playerList addObject:[NSString stringWithUTF8String:n.c_str()]];
    }

    NSDictionary *bodyDict = @{ @"players": playerList };

    NSError *encodeErr = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict
                                                       options:0
                                                         error:&encodeErr];
    if (!jsonData || encodeErr) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: JSON encode error=%@", encodeErr);
        return;
    }

    NSURL *url = [NSURL URLWithString:@"https://acapiforapk.onrender.com/api/players"];
    if (!url) {
        NSLog(@"[Kitty] SendNetPlayersToAPI: invalid URL");
        return;
    }

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = jsonData;

    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithRequest:req
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error)
    {
        if (error) {
            NSLog(@"[Kitty] SendNetPlayersToAPI: POST error=%@", error);
            return;
        }
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        NSLog(@"[Kitty] SendNetPlayersToAPI: POST /api/players status %ld",
              (long)http.statusCode);
    }];

    [task resume];
}
static bool GetNetPlayerPlayerRef(Il2CppObject* netPlayer, PlayerRefNative* outRef)
{
    if (!netPlayer || !outRef) return false;

    Il2CppClass* npCls = s_object_get_class(netPlayer);
    if (!npCls) return false;

    MethodInfo* mGet = s_get_method_from_name(npCls, "get_playerRef", 0);
    if (!mGet || !mGet->methodPointer) return false;

    Il2CppException* ex = nullptr;
    Il2CppObject* boxed = s_runtime_invoke(mGet, netPlayer, nullptr, &ex);
    if (ex || !boxed) return false;

    void* payload = (char*)boxed + sizeof(Il2CppObject);
    memcpy(outRef, payload, sizeof(PlayerRefNative));
    return true;
}
static bool CallRoboMonkeStartup(Il2CppObject* roboMonkeInstance, const PlayerRefNative& pr)
{
    if (!roboMonkeInstance) return false;

    static MethodInfo* mRpc = nullptr;
    if (!mRpc) {
        Il2CppClass* cls = s_object_get_class(roboMonkeInstance);
        if (!cls) return false;
        mRpc = s_get_method_from_name(cls, "RPC_Startup", 1);
        if (!mRpc || !mRpc->methodPointer) return false;
    }

    using t_RPC = void(*)(Il2CppObject*, PlayerRefNative);
    t_RPC RPC_Startup = (t_RPC)STRIP_FP(mRpc->methodPointer);
    RPC_Startup(roboMonkeInstance, pr);
    return true;
}
static bool CallTrampolineBounce(Il2CppObject* trampolineBounce, const PlayerRefNative& pr)
{
    if (!trampolineBounce) return false;

    static MethodInfo* mRpc = nullptr;
    if (!mRpc) {
        Il2CppClass* cls = s_object_get_class(trampolineBounce);
        if (!cls) return false;
        mRpc = s_get_method_from_name(cls, "RPC_BouncePlayer", 1);
        if (!mRpc || !mRpc->methodPointer) return false;
    }

    using t_RPC = void(*)(Il2CppObject*, PlayerRefNative);
    t_RPC RPC_BouncePlayer = (t_RPC)STRIP_FP(mRpc->methodPointer);
    RPC_BouncePlayer(trampolineBounce, pr);
    return true;
}
static inline bool ReadBoxedBool(Il2CppObject* o, bool& outB) {
    if (!o) return false;
    outB = *(bool*)((char*)o + sizeof(Il2CppObject));
    return true;
}
static inline bool ReadBoxedUInt32(Il2CppObject* o, uint32_t& outU) {
    if (!o) return false;
    outU = *(uint32_t*)((char*)o + sizeof(Il2CppObject));
    return true;
}
static std::vector<uint32_t> GetAllMobIds()
{
    std::vector<uint32_t> keys;

    MethodInfo* m_getDict = s_get_method_from_name(MobController, "get_spawnedMobs", 0);
    if (!m_getDict || !m_getDict->methodPointer) { NSLog(@"[MobKeys] missing get_spawnedMobs"); return keys; }

    Il2CppException* ex = nullptr;
    Il2CppObject* dictObj = s_runtime_invoke(m_getDict, nullptr, nullptr, &ex);
    if (ex || !dictObj) { NSLog(@"[MobKeys] get_spawnedMobs ex=%p dict=%p", ex, dictObj); return keys; }

    Il2CppClass* dictCls = s_object_get_class(dictObj);
    MethodInfo* m_getCount = s_get_method_from_name(dictCls, "get_Count", 0);
    if (m_getCount && m_getCount->methodPointer) {
        ex = nullptr;
        Il2CppObject* boxedCnt = s_runtime_invoke(m_getCount, dictObj, nullptr, &ex);
        if (!ex && boxedCnt) {
            int cnt = *(int*)((char*)boxedCnt + sizeof(Il2CppObject));
            if (cnt > 0 && cnt < 100000) keys.reserve((size_t)cnt);
            NSLog(@"[MobKeys] pre-reserve count=%d", cnt);
        }
    }

    MethodInfo* m_getKeys = s_get_method_from_name(dictCls, "get_Keys", 0);
    if (!m_getKeys || !m_getKeys->methodPointer) { NSLog(@"[MobKeys] missing get_Keys"); return keys; }

    ex = nullptr;
    Il2CppObject* keysObj = s_runtime_invoke(m_getKeys, dictObj, nullptr, &ex);
    if (ex || !keysObj) { NSLog(@"[MobKeys] get_Keys ex=%p keys=%p", ex, keysObj); return keys; }

    Il2CppClass* keysCls = s_object_get_class(keysObj);
    MethodInfo* m_GetEnumerator = s_get_method_from_name(keysCls, "GetEnumerator", 0);
    if (!m_GetEnumerator || !m_GetEnumerator->methodPointer) { NSLog(@"[MobKeys] missing Keys.GetEnumerator"); return keys; }

    ex = nullptr;
    Il2CppObject* boxedEnum = s_runtime_invoke(m_GetEnumerator, keysObj, nullptr, &ex);
    if (ex || !boxedEnum) { NSLog(@"[MobKeys] GetEnumerator ex=%p enum=%p", ex, boxedEnum); return keys; }

    // UNBOX the enumerator valuetype and call instance methods on the unboxed buffer
    Il2CppClass* enumCls = s_object_get_class(boxedEnum);
    size_t enumValueSize = (size_t)(enumCls->instance_size - sizeof(Il2CppObject)); // payload size
    std::vector<uint8_t> enumBuf(enumValueSize);
    memcpy(enumBuf.data(), (char*)boxedEnum + sizeof(Il2CppObject), enumValueSize);
    void* enumThis = enumBuf.data();

    MethodInfo* m_MoveNext   = s_get_method_from_name(enumCls, "MoveNext", 0);
    MethodInfo* m_getCurrent = s_get_method_from_name(enumCls, "get_Current", 0);
    if (!m_MoveNext || !m_MoveNext->methodPointer || !m_getCurrent || !m_getCurrent->methodPointer) {
        NSLog(@"[MobKeys] missing MoveNext/get_Current");
        return keys;
    }

    const int kHardCap = 100000;
    for (int step = 0; step < kHardCap; ++step) {
        ex = nullptr;
        Il2CppObject* boxedHasNext = s_runtime_invoke(m_MoveNext, enumThis, nullptr, &ex);
        if (ex || !boxedHasNext) { NSLog(@"[MobKeys] MoveNext ex=%p obj=%p", ex, boxedHasNext); break; }

        bool hasNext = false;
        if (!ReadBoxedBool(boxedHasNext, hasNext)) { NSLog(@"[MobKeys] MoveNext bool read fail"); break; }
        if (!hasNext) break;

        ex = nullptr;
        Il2CppObject* boxedKey = s_runtime_invoke(m_getCurrent, enumThis, nullptr, &ex);
        if (ex || !boxedKey) { NSLog(@"[MobKeys] get_Current ex=%p key=%p", ex, boxedKey); break; }

        uint32_t key = 0;
        if (!ReadBoxedUInt32(boxedKey, key)) { NSLog(@"[MobKeys] key read fail"); break; }
        keys.push_back(key);
    }

    NSLog(@"[MobKeys] collected %zu keys", keys.size());
    return keys;
}
static Il2CppObject* GetPooledPrefab_ItemBox()
{
    if (!GameObject || !Component || !s_get_method_from_name || !s_runtime_invoke ||
        !s_field_get_value || !s_class_get_field_from_name || !s_object_get_class) {
        NSLog(@"[Kitty] GetPooledPrefab_ItemBox: missing il2cpp ptrs");
        return nullptr;
    }

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] FindObjectsOfType(Type) not found");
            return nullptr;
        }
    }

    Il2CppObject* typeComponent = s_type_get_object ? s_type_get_object(&Component->byval_arg) : nullptr;
    if (!typeComponent) { NSLog(@"[Kitty] typeof(Component) failed"); return nullptr; }

    Il2CppException* ex = nullptr;
    void* argsFO[1] = { typeComponent };
    Il2CppObject* arrObj = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFO, &ex);
    if (ex || !arrObj) { NSLog(@"[Kitty] FindObjectsOfType ex=%p arr=%p", ex, arrObj); return nullptr; }

    Il2CppArray* comps = (Il2CppArray*)arrObj;
    if (!comps || comps->max_length == 0) { NSLog(@"[Kitty] no Components in scene"); return nullptr; }

    Il2CppObject* appPrefabPool = nullptr;
    Il2CppObject** elems = (Il2CppObject**)((char*)comps + sizeof(Il2CppArray));
    for (il2cpp_array_size_t i = 0; i < comps->max_length; ++i) {
        Il2CppObject* c = elems[i];
        if (!c) continue;
        Il2CppClass* k = s_object_get_class(c);
        if (!k) continue;
        if (k->namespaze && k->name &&
            strcmp(k->namespaze, "AnimalCompany") == 0 &&
            strcmp(k->name, "AppPrefabPool") == 0) {
            appPrefabPool = c;
            break;
        }
    }
    if (!appPrefabPool) { NSLog(@"[Kitty] AppPrefabPool instance not found"); return nullptr; }

    Il2CppClass* appPPCls = s_object_get_class(appPrefabPool);
    FieldInfo* f_pool = s_class_get_field_from_name(appPPCls, "_pool");
    if (!f_pool) { NSLog(@"[Kitty] _pool field missing"); return nullptr; }

    Il2CppObject* prefabPoolObj = nullptr;
    s_field_get_value(appPrefabPool, f_pool, &prefabPoolObj);
    if (!prefabPoolObj) { NSLog(@"[Kitty] _pool is null"); return nullptr; }

    Il2CppClass* prefabPoolCls = s_object_get_class(prefabPoolObj);
    FieldInfo* f_dict = s_class_get_field_from_name(prefabPoolCls, "_poolsByPrefabObject");
    if (!f_dict) { NSLog(@"[Kitty] _poolsByPrefabObject field missing"); return nullptr; }

    Il2CppObject* dictObj = nullptr;
    s_field_get_value(prefabPoolObj, f_dict, &dictObj);
    if (!dictObj) { NSLog(@"[Kitty] _poolsByPrefabObject is null"); return nullptr; }

    Il2CppClass* dictCls = s_object_get_class(dictObj);
    MethodInfo* m_getKeys = s_get_method_from_name(dictCls, "get_Keys", 0);
    if (!m_getKeys || !m_getKeys->methodPointer) { NSLog(@"[Kitty] Dictionary.get_Keys missing"); return nullptr; }

    ex = nullptr;
    Il2CppObject* keysObj = s_runtime_invoke(m_getKeys, dictObj, nullptr, &ex);
    if (ex || !keysObj) { NSLog(@"[Kitty] get_Keys ex=%p", ex); return nullptr; }

    Il2CppClass* keysCls = s_object_get_class(keysObj);
    MethodInfo* m_GetEnumerator = s_get_method_from_name(keysCls, "GetEnumerator", 0);
    if (!m_GetEnumerator || !m_GetEnumerator->methodPointer) {
        m_GetEnumerator = s_get_method_from_name(keysCls, "System.Collections.IEnumerable.GetEnumerator", 0);
    }
    if (!m_GetEnumerator || !m_GetEnumerator->methodPointer) { NSLog(@"[Kitty] Keys.GetEnumerator missing"); return nullptr; }

    ex = nullptr;
    Il2CppObject* boxedEnum = s_runtime_invoke(m_GetEnumerator, keysObj, nullptr, &ex);
    if (ex || !boxedEnum) { NSLog(@"[Kitty] GetEnumerator ex=%p", ex); return nullptr; }

    Il2CppClass* enumCls = s_object_get_class(boxedEnum);
    MethodInfo* m_MoveNext   = s_get_method_from_name(enumCls, "MoveNext", 0);
    MethodInfo* m_getCurrent = s_get_method_from_name(enumCls, "get_Current", 0);
    if (!m_MoveNext || !m_MoveNext->methodPointer || !m_getCurrent || !m_getCurrent->methodPointer) {
        NSLog(@"[Kitty] MoveNext/get_Current missing");
        return nullptr;
    }

    size_t enumPayloadSize = (size_t)(enumCls->instance_size - sizeof(Il2CppObject));
    std::vector<uint8_t> enumBuf(enumPayloadSize);
    memcpy(enumBuf.data(), (char*)boxedEnum + sizeof(Il2CppObject), enumPayloadSize);
    void* enumThis = enumBuf.data();

    MethodInfo* m_getName = s_get_method_from_name(GameObject, "get_name", 0);
    if (!m_getName || !m_getName->methodPointer) { NSLog(@"[Kitty] GameObject.get_name missing"); return nullptr; }

    NSLog(@"[Kitty] --- Prefabs in _poolsByPrefabObject ---");
    const int kHardCap = 100000;
    for (int step = 0; step < kHardCap; ++step) 
    {
        ex = nullptr;
        Il2CppObject* boxedHasNext = s_runtime_invoke(m_MoveNext, enumThis, nullptr, &ex);
        if (ex || !boxedHasNext) { NSLog(@"[Kitty] MoveNext ex=%p", ex); break; }

        bool hasNext = false;
        if (!ReadBoxedBool(boxedHasNext, hasNext)) { NSLog(@"[Kitty] MoveNext bool read fail"); break; }
        if (!hasNext) break;

        ex = nullptr;
        Il2CppObject* keyGO = s_runtime_invoke(m_getCurrent, enumThis, nullptr, &ex);
        if (ex || !keyGO) { NSLog(@"[Kitty] get_Current ex=%p key=%p", ex, keyGO); break; }

        ex = nullptr;
        Il2CppObject* nameObj = s_runtime_invoke(m_getName, keyGO, nullptr, &ex);
        if (ex || !nameObj) { NSLog(@"[Kitty] get_name ex=%p", ex); continue; }

        Il2CppString* s = (Il2CppString*)nameObj;
        std::string n = il2cpp_string_to_std(s, string_chars, string_length);
        NSLog(@"[Kitty] Prefab: %s", n.c_str());

        if (n == "ItemBox") {
            NSLog(@"[Kitty] Found ItemBox prefab");
            return keyGO; // this is the UnityEngine.GameObject
        }
    }
    NSLog(@"[Kitty] --- end (ItemBox not found) ---");
    return nullptr;
}
static MethodInfo* FindSpawnItemGO(Il2CppClass* klass) {
    void* it = nullptr;
    for (const MethodInfo* m; (m = s_class_get_methods(klass, &it)); ) 
    {
        if (strcmp(m->name, "Spawn") != 0) continue;

        if (m->parameters_count != 6) continue;
        if (!m->parameters) continue;
        const Il2CppType* p0 = m->parameters[0];
        if (!p0) continue;

        const char* p0name = s_type_get_name(p0);
        if (p0name && strstr(p0name, "UnityEngine.GameObject")) {
            return const_cast<MethodInfo*>(m);
        }
    }
    return nullptr;
}
static MethodInfo* FindLoadScene(Il2CppClass* klass) {
    void* it = nullptr;
    for (const MethodInfo* m; (m = s_class_get_methods(klass, &it)); ) {
        if (strcmp(m->name, "LoadScene") != 0) continue;
        if (m->parameters_count != 4) continue;
        if (!m->parameters) continue;

        const Il2CppType* p0 = m->parameters[0];
        if (!p0) continue;

        const char* p0name = s_type_get_name(p0);
        if (!p0name) continue;
        if (strcmp(p0name, "System.String") != 0) continue;

        return const_cast<MethodInfo*>(m);
    }
    return nullptr;
}

static void LoadSceneByName(const char* sceneNameCStr) 
{
    if (!runner || !sceneNameCStr) return;

    static MethodInfo* m_LoadScene = nullptr;
    if (!m_LoadScene) {
        m_LoadScene = FindLoadScene(NetworkRunner);
        if (!m_LoadScene || !m_LoadScene->methodPointer) return;
    }

    Il2CppString* sceneName = s_string_new(sceneNameCStr);

    int32_t loadSceneMode    = 0;
    int32_t localPhysicsMode = 0;
    bool setActiveOnLoad     = true;

    void* args[4] = {
        sceneName,
        &loadSceneMode,
        &localPhysicsMode,
        &setActiveOnLoad
    };

    Il2CppException* ex = nullptr;
    s_runtime_invoke(m_LoadScene, runner, args, &ex);
}



static void FillRootItems(Il2CppObject* backpack)
{
    if (!backpack || !BackpackItem || !s_get_method_from_name || !s_runtime_invoke || !s_object_get_class) {
        NSLog(@"[Kitty] FillRootItems: missing il2cpp symbols/classes");
        return;
    }

    // Get the rootItems property getter
    static MethodInfo* m_getRootItems = nullptr;
    if (!m_getRootItems) {
        m_getRootItems = s_get_method_from_name(BackpackItem, "get_rootItems", 0);
        if (!m_getRootItems || !m_getRootItems->methodPointer) {
            NSLog(@"[Kitty] FillRootItems: rootItems getter not found");
            return;
        }
    }

    // Invoke getter -> boxed NetworkLinkedList<short> (struct boxed as object)
    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getRootItems, backpack, nullptr, &ex);
    if (ex || !boxedList) {
        NSLog(@"[Kitty] FillRootItems: get_rootItems failed ex=%p list=%p", ex, boxedList);
        return;
    }

    // Unbox: pointer to the struct data used as 'this' for instance method calls
    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    // Resolve methods from the boxed list's class
    Il2CppClass* listClass = s_object_get_class(boxedList);
    if (!listClass) {
        NSLog(@"[Kitty] FillRootItems: listClass NULL");
        return;
    }

    static MethodInfo* m_Add = nullptr;
    static MethodInfo* m_getCapacity = nullptr;
    static MethodInfo* m_getCount = nullptr;

    if (!m_Add) {
        m_Add = s_get_method_from_name(listClass, "Add", 1);
        if (!m_Add || !m_Add->methodPointer) {
            NSLog(@"[Kitty] FillRootItems: Add(short) not found");
            return;
        }
    }

    if (!m_getCapacity) {
        m_getCapacity = s_get_method_from_name(listClass, "get_Capacity", 0);
        // optional; if missing, we continue anyway
    }

    if (!m_getCount) {
        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        // optional; if missing, we continue anyway
    }

    int cap = -1;
    int cnt = -1;

    if (m_getCapacity) {
        ex = nullptr;
        Il2CppObject* boxedCap = s_runtime_invoke(m_getCapacity, listThis, nullptr, &ex);
        if (!ex && boxedCap) cap = *(int*)((char*)boxedCap + sizeof(Il2CppObject));
    }
    if (m_getCount) {
        ex = nullptr;
        Il2CppObject* boxedCnt = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
        if (!ex && boxedCnt) cnt = *(int*)((char*)boxedCnt + sizeof(Il2CppObject));
    }

    NSLog(@"[Kitty] FillRootItems: capacity=%d count=%d (target add=24)", cap, cnt);

    // Add 24 shorts of value 1
    for (int i = 0; i < 80; ++i) {
        int16_t v = (int16_t)1;
        void* argsAdd[1] = { &v };

        ex = nullptr;
        s_runtime_invoke(m_Add, listThis, argsAdd, &ex);
        if (ex) {
            NSLog(@"[Kitty] FillRootItems: Add[%d]=1 threw ex=%p", i, ex);
            // keep going; Fusion linked list may hard-cap at capacity (23) and fail beyond
            continue;
        }
    }

    // Post-state (best-effort)
    if (m_getCount) {
        ex = nullptr;
        Il2CppObject* boxedCnt2 = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
        if (!ex && boxedCnt2) {
            int cnt2 = *(int*)((char*)boxedCnt2 + sizeof(Il2CppObject));
            NSLog(@"[Kitty] FillRootItems: done, new count=%d", cnt2);
            return;
        }
    }

    NSLog(@"[Kitty] FillRootItems: done");
}
static void DuplicateFirstItem(Il2CppObject* backpack)
{
    if (!backpack || !BackpackItem || !s_get_method_from_name || !s_runtime_invoke || !s_object_get_class) {
        NSLog(@"[Kitty] DuplicateFirstItem: missing il2cpp symbols/classes");
        return;
    }

    // Get the allItems property getter
    static MethodInfo* m_getAllItems = nullptr;
    if (!m_getAllItems) {
        m_getAllItems = s_get_method_from_name(BackpackItem, "get_allItems", 0);
        if (!m_getAllItems || !m_getAllItems->methodPointer) {
            NSLog(@"[Kitty] DuplicateFirstItem: get_allItems not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedDict = s_runtime_invoke(m_getAllItems, backpack, nullptr, &ex);
    if (ex || !boxedDict) {
        NSLog(@"[Kitty] DuplicateFirstItem: get_allItems failed ex=%p dict=%p", ex, boxedDict);
        return;
    }

    void* dictThis = (void*)((char*)boxedDict + sizeof(Il2CppObject));
    Il2CppClass* dictClass = s_object_get_class(boxedDict);
    if (!dictClass) {
        NSLog(@"[Kitty] DuplicateFirstItem: dictClass NULL");
        return;
    }

    // Resolve enumerator and set_Item
    static MethodInfo* m_GetEnumerator = nullptr;
    static MethodInfo* m_setItem = nullptr;
    if (!m_GetEnumerator || !m_setItem) {
        m_GetEnumerator = s_get_method_from_name(dictClass, "GetEnumerator", 0);
        m_setItem       = s_get_method_from_name(dictClass, "set_Item", 2);
        if (!m_setItem) m_setItem = s_get_method_from_name(dictClass, "Set", 2);
        if (!m_GetEnumerator || !m_setItem || !m_GetEnumerator->methodPointer || !m_setItem->methodPointer) {
            NSLog(@"[Kitty] DuplicateFirstItem: dict methods missing");
            return;
        }
    }

    // Get enumerator
    ex = nullptr;
    Il2CppObject* boxedEnum = s_runtime_invoke(m_GetEnumerator, dictThis, nullptr, &ex);
    if (ex || !boxedEnum) {
        NSLog(@"[Kitty] DuplicateFirstItem: GetEnumerator failed ex=%p enum=%p", ex, boxedEnum);
        return;
    }

    void* enumThis = (void*)((char*)boxedEnum + sizeof(Il2CppObject));
    Il2CppClass* enumClass = s_object_get_class(boxedEnum);
    if (!enumClass) {
        NSLog(@"[Kitty] DuplicateFirstItem: enumClass NULL");
        return;
    }

    static MethodInfo* m_MoveNext   = nullptr;
    static MethodInfo* m_getCurrent = nullptr;
    static FieldInfo*  f_kv_key     = nullptr;
    static FieldInfo*  f_kv_value   = nullptr;
    if (!m_MoveNext || !m_getCurrent) {
        m_MoveNext   = s_get_method_from_name(enumClass, "MoveNext", 0);
        m_getCurrent = s_get_method_from_name(enumClass, "get_Current", 0);
        if (!m_MoveNext || !m_getCurrent || !m_MoveNext->methodPointer || !m_getCurrent->methodPointer) {
            NSLog(@"[Kitty] DuplicateFirstItem: MoveNext/get_Current not found");
            return;
        }
    }

    // Grab the first KV
    ex = nullptr;
    Il2CppObject* boxedHasMore = s_runtime_invoke(m_MoveNext, enumThis, nullptr, &ex);
    if (ex || !boxedHasMore) {
        NSLog(@"[Kitty] DuplicateFirstItem: MoveNext failed ex=%p", ex);
        return;
    }
    bool hasMore = *(bool*)((char*)boxedHasMore + sizeof(Il2CppObject));
    if (!hasMore) {
        NSLog(@"[Kitty] DuplicateFirstItem: dict empty");
        return;
    }

    ex = nullptr;
    Il2CppObject* boxedKV = s_runtime_invoke(m_getCurrent, enumThis, nullptr, &ex);
    if (ex || !boxedKV) {
        NSLog(@"[Kitty] DuplicateFirstItem: get_Current failed ex=%p kv=%p", ex, boxedKV);
        return;
    }

    Il2CppClass* kvClass = s_object_get_class(boxedKV);
    if (!kvClass) {
        NSLog(@"[Kitty] DuplicateFirstItem: kvClass NULL");
        return;
    }
    if (!f_kv_key || !f_kv_value) {
        f_kv_key   = s_class_get_field_from_name(kvClass, "key");
        f_kv_value = s_class_get_field_from_name(kvClass, "value");
        if (!f_kv_key || !f_kv_value) {
            NSLog(@"[Kitty] DuplicateFirstItem: key/value fields not found");
            return;
        }
    }

    short baseKey = 0;
    uint8_t valueBuf[64] = {0}; // enough for ContainedItem
    s_field_get_value(boxedKV, f_kv_key,   &baseKey);
    s_field_get_value(boxedKV, f_kv_value, valueBuf);

    // Duplicate 80 times with new keys
    for (int i = 1; i <= 80; ++i) {
        short newKey = baseKey + i;
        void* argsSet[2] = { &newKey, valueBuf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, dictThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] DuplicateFirstItem: set_Item key=%d ex=%p", (int)newKey, ex);
            continue;
        }
    }

    NSLog(@"[Kitty] DuplicateFirstItem: duplicated first entry to 81 total");
}
static void ExecutePlayerAction()
{
    if (!GameObject || !NetPlayer || !s_get_method_from_name || !s_runtime_invoke) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: il2cpp not ready");
        return;
    }

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) 
    {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType(Type) not found");
            return;
        }
    }

    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);

    Il2CppException* ex = nullptr;
    void* argsFO[1] = { typeNetPlayer };
    Il2CppObject* arrObj = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFO, &ex);
    if (ex || !arrObj) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType ex=%p arr=%p", ex, arrObj);
        return;
    }

    Il2CppArray* arr = (Il2CppArray*)arrObj;
    if (!arr || arr->max_length == 0) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: no NetPlayer instances");
        return;
    }
    static MethodInfo* m_getDisplayName = nullptr;
    if (!m_getDisplayName) {
        m_getDisplayName = s_get_method_from_name(NetPlayer, "get_displayName", 0);
        if (!m_getDisplayName || !m_getDisplayName->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: get_displayName not found");
            return;
        }
    }
        NSLog(@"[Kitty] FindJeremyAndDoSomething: storing sh..");

    Il2CppObject** elems = (Il2CppObject**)((char*)arr + sizeof(Il2CppArray));

    auto nm_applyBuff  = s_get_method_from_name(NetPlayer, "RPC_ApplyBuff", 1);
    auto ApplyBuff = (void(*)(Il2CppObject*, int))STRIP_FP(nm_applyBuff->methodPointer);

    MethodInfo* m_AddForce = s_get_method_from_name(NetPlayer, "RPC_AddForce", 1);
    if (!m_AddForce || !m_AddForce->methodPointer) return;
    using t_AddForce = void(*)(Il2CppObject*, Vector3);
    auto AddForce = (t_AddForce)STRIP_FP(m_AddForce->methodPointer);

    auto nm_addMoney  = s_get_method_from_name(NetPlayer, "RPC_AddPlayerMoney", 1);
    auto AddPlayerMoney = (void(*)(Il2CppObject*, int))STRIP_FP(nm_addMoney->methodPointer);

    auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
    auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
    Il2CppObject* nsInstance = get_instance();

    auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
    auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
    Il2CppObject* vr = get_vrPlayer(nsInstance);

    auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
    if (!nm_get_position || !nm_get_position->methodPointer) return;
    auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

    Vector3 camPosition = get_position(nsInstance);

    MethodInfo* m_Teleport = s_get_method_from_name(NetPlayer, "RPC_Teleport", 1);
    if (!m_Teleport || !m_Teleport->methodPointer) return;
    using t_Teleport = void(*)(Il2CppObject*, Vector3);
    auto Teleport = (t_Teleport)STRIP_FP(m_Teleport->methodPointer);

    MethodInfo* m_Muffle = s_get_method_from_name(NetPlayer, "RPC_SetMuffledVoiceEnabled", 1);
    if (!m_Muffle || !m_Muffle->methodPointer) return;
    using t_Muffle = void(*)(Il2CppObject*, bool);
    auto Muffle = (t_Muffle)STRIP_FP(m_Muffle->methodPointer);

    MethodInfo* m_Squeek = s_get_method_from_name(NetPlayer, "RPC_SetSqueakyVoiceEnabled", 1);
    if (!m_Squeek || !m_Squeek->methodPointer) return;
    using t_Squeek = void(*)(Il2CppObject*, bool);
    auto Squeek = (t_Squeek)STRIP_FP(m_Squeek->methodPointer);

    MethodInfo* m_TagAsStinky = s_get_method_from_name(NetPlayer, "RPC_TagAsStinky", 0);
    if (!m_TagAsStinky || !m_TagAsStinky->methodPointer) return;
    using t_TagAsStinky = void(*)(Il2CppObject*);
    auto TagAsStinky = (t_TagAsStinky)STRIP_FP(m_TagAsStinky->methodPointer);

    NSLog(@"[Kitty] FindJeremyAndDoSomething: nigger...");

    MethodInfo* m_PlayerHit = s_get_method_from_name(NetPlayer, "RPC_PlayerHit", 3);
    if (!m_PlayerHit || !m_PlayerHit->methodPointer) return;
    using t_PlayerHit = void(*)(Il2CppObject*, int, Vector3, Il2CppObject*);
    auto PlayerHit = (t_PlayerHit)STRIP_FP(m_PlayerHit->methodPointer);

    MethodInfo* m_RoboMonkeItem = s_get_method_from_name(RoboMonkeItem, "RPC_Startup", 1);
    if (!m_RoboMonkeItem || !m_RoboMonkeItem->methodPointer) return;
    using t_RoboMonkeItem = void(*)(Il2CppObject*, PlayerRefNative);
    auto RoboMonkeItem = (t_RoboMonkeItem)STRIP_FP(m_RoboMonkeItem->methodPointer);

    MethodInfo* m_get_objectID = s_get_method_from_name(NetPlayer, "get_objectID", 0);
    if (!m_get_objectID || !m_get_objectID->methodPointer) return;
    using t_get_objectID = int(*)(Il2CppObject*);
    auto get_objectID = (t_get_objectID)STRIP_FP(m_get_objectID->methodPointer);

    MethodInfo* m_get_position = s_get_method_from_name(Transform, "get_position", 0);
    if (!m_get_position || !m_get_position->methodPointer) return;
    using t_get_position = Vector3(*)(Il2CppObject*);
    auto transform_get_position = (t_get_position)STRIP_FP(m_get_position->methodPointer);

    MethodInfo* m_SpawnPickup = s_get_method_from_name(PickupManager, "RPC_SpawnPickup_Internal", 4);
    if (!m_SpawnPickup || !m_SpawnPickup->methodPointer) return;
    using t_SpawnPickup = void(*)(Il2CppObject*, int, Vector3, int);
    auto SpawnPickup = (t_SpawnPickup)STRIP_FP(m_SpawnPickup->methodPointer);

    MethodInfo* m_RPC_SetJellyEffect = s_get_method_from_name(NetPlayer, "RPC_SetJellyEffect", 2);
    if (!m_RPC_SetJellyEffect || !m_RPC_SetJellyEffect->methodPointer) return;
    using t_RPC_SetJellyEffect = void(*)(Il2CppObject*, float, float);
    auto RPC_SetJellyEffect = (t_RPC_SetJellyEffect)STRIP_FP(m_RPC_SetJellyEffect->methodPointer);

    MethodInfo* m_RPC_ShakeScreen = s_get_method_from_name(NetPlayer, "RPC_ShakeScreen", 5);
    if (!m_RPC_ShakeScreen || !m_RPC_ShakeScreen->methodPointer) return;
    using t_RPC_ShakeScreen = void(*)(Il2CppObject*, float, float, float, float, float);
    auto RPC_ShakeScreen = (t_RPC_ShakeScreen)STRIP_FP(m_RPC_ShakeScreen->methodPointer);

    MethodInfo* m_RPC_SetTeam = s_get_method_from_name(NetPlayer, "RPC_SetTeam", 1);
    if (!m_RPC_SetTeam || !m_RPC_SetTeam->methodPointer) return;
    using t_RPC_SetTeam = void(*)(Il2CppObject*, uint8_t);
    auto RPC_SetTeam = (t_RPC_SetTeam)STRIP_FP(m_RPC_SetTeam->methodPointer);    

    MethodInfo* m_SetMass = s_get_method_from_name(GrabbableObject, "SetMass", 1);
    if (!m_SetMass || !m_SetMass->methodPointer) return;
    using t_SetMass = void(*)(Il2CppObject*, float);
    auto SetMass = (t_SetMass)STRIP_FP(m_SetMass->methodPointer);

    Il2CppObject* body = nullptr;
    FieldInfo* fbody = s_class_get_field_from_name(NetPlayer, "body");

    Il2CppObject* _spawnPrefab = nullptr;
    FieldInfo* f_spawnPrefab = s_class_get_field_from_name(NetObjectSpawnGroup, "_spawnPrefab");

    Il2CppObject* _fineRigObj = nullptr;
    FieldInfo* f_fineRigObj = s_class_get_field_from_name(NetPlayer, "_fineRigObj");

    auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
    auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

    MethodInfo* m_Destroy = s_get_method_from_name(NetworkRunner, "Despawn", 1);
    if (!m_Destroy || !m_Destroy->methodPointer) return;
    using t_Destroy = void(*)(Il2CppObject*, Il2CppObject*);
    auto Destroy = (t_Destroy)STRIP_FP(m_Destroy->methodPointer);

    NSLog(@"[Kitty] FindJeremyAndDoSomething: stored evrything...");

    for (il2cpp_array_size_t i = 0; i < arr->max_length; ++i) 
    {
        Il2CppObject* np = elems[i];
        if (!np) continue;

        ex = nullptr;
        Il2CppObject* nameObj = s_runtime_invoke(m_getDisplayName, np, nullptr, &ex);
        if (ex || !nameObj) 
        {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: get_displayName failed idx=%u ex=%p",
                  (unsigned)i, ex);
            continue;
        }

        Il2CppString* il2Name = (Il2CppString*)nameObj;
        std::string name = il2cpp_string_to_std(il2Name, string_chars, string_length);

        std::string lower = name;
        std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
        if (name == g_cfgTargetPlayer) 
        {
            if(g_cfgTargetAction == "Fling")
            {
                AddForce(np, Vector3{0.f, 999.f, 0.f});
            }
            if(g_cfgTargetAction == "Kick")
            {
                Teleport(np, Vector3{-999.f, -99999.f, -999.f});
            }
            if(g_cfgTargetAction == "Kill")
            {
                PlayerHit(np, 938232, Vector3{0.f, 0.f, 0.f,}, nullptr);
            }
             if(g_cfgTargetAction == "Moon Map Tp")
            {
                Teleport(np, Vector3{999.f, 999.f, 999.f});
            }
            if(g_cfgTargetAction == "Add Money")
            {
                AddPlayerMoney(np, 9999999);
            }
            if(g_cfgTargetAction == "Shrink")
            {
                ApplyBuff(np, 10);
            }
            if(g_cfgTargetAction == "Grow")
            {
                ApplyBuff(np, 7);
            }
            if(g_cfgTargetAction == "Stink Jump")
            {
                ApplyBuff(np, 4);
            }
            if(g_cfgTargetAction == "Fart Boost")
            {
                ApplyBuff(np, 11);
            }
            if(g_cfgTargetAction == "Bloodlust")
            {
                ApplyBuff(np, 6);
            }
            if(g_cfgTargetAction == "Big Head")
            {
                ApplyBuff(np, 5);
            }
            if(g_cfgTargetAction == "Flashbang")
            {
                ApplyBuff(np, 13);
            }
            if(g_cfgTargetAction == "Love")
            {
                ApplyBuff(np, 15);
            }
            if(g_cfgTargetAction == "Speedboost")
            {
                ApplyBuff(np, 16);
            }
            if(g_cfgTargetAction == "Cheese Body")
            {
                ApplyBuff(np, 22);
            }
            if(g_cfgTargetAction == "Illness")
            {
                ApplyBuff(np, 23);
            }
            if(g_cfgTargetAction == "Teleport")
            {
                Teleport(np, camPosition);
            }
            if(g_cfgTargetAction == "Muffle Voice")
            {
                Muffle(np, true);
            }
            if(g_cfgTargetAction == "Squeeky Voice")
            {
                Squeek(np, true);
            }
            if(g_cfgTargetAction == "Tag Stinky")
            {
                TagAsStinky(np);
            }
            if(g_cfgTargetAction == "Ammo Giveaway")
            {
                s_field_get_value(np, fbody, &body);
                SpawnPickup(runner, 1, transform_get_position(body), 100);
            }
            if(g_cfgTargetAction == "Nut Giveaway")
            {
                s_field_get_value(np, fbody, &body);
                SpawnPickup(runner, 2, transform_get_position(body), 100);
            }
            if(g_cfgTargetAction == "Robo Monke")
            {
                PlayerRefNative pr;
                if (GetNetPlayerPlayerRef(np, &pr))
                {
                    Il2CppObject* goRobo = SpawnItem(CreateMonoString("item_robo_monke"), GetCamPosition(), -127, 0, 0);

                    Il2CppObject* robo = GO_GetComponentInChildren(goRobo, roboMonkeItemType);

                    CallRoboMonkeStartup(robo, pr);
                }
            }
            if(g_cfgTargetAction == "Gift Car")
            {
                s_field_get_value(np, fbody, &body);
                MethodInfo* m_getName = s_get_method_from_name(GameObject, "get_name", 0);

                Il2CppException* exees = nullptr;
                void* argsFOT[1] = { netObjectSpawnGroupType };
                Il2CppObject* arrPrefabs = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFOT, &exees);
                if (exees || !arrPrefabs) {
                    NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType ex=%p arr=%p", ex, arrObj);
                    return;
                }

                Il2CppArray* arrp = (Il2CppArray*)arrPrefabs;

                Il2CppObject** elemss = (Il2CppObject**)((char*)arrp + sizeof(Il2CppArray));

                for (il2cpp_array_size_t i = 0; i < arrp->max_length; ++i) 
                {
                    Il2CppObject* nosg = elemss[i];
                    if (!nosg) continue;

                    s_field_get_value(nosg, f_spawnPrefab, &_spawnPrefab);

                    Vector3 pos = transform_get_position(body);
                    Quaternion rot{0.f,0.f,0.f,1.f};
                    Il2CppObject* prefab = _spawnPrefab;
                }
            }
            if(g_cfgTargetAction == "Jellify")
            {
               RPC_SetJellyEffect(np, 50.f, 30.f);
            }
            if(g_cfgTargetAction == "Invisibility")
            {
                RPC_SetJellyEffect(np, 500.f, 500000000.f);
            }
            if(g_cfgTargetAction == "Shake Screen")
            {
                RPC_ShakeScreen(np, 50.f, 2.f, 2.f, 50.f, 50.f);
            }
            if(g_cfgTargetAction == "Shake Screen Insane")
            {
                LoadSceneByName("Adventure_World");
                //RPC_ShakeScreen(np, 50.f, 1.f, 1.f, 5000.f, 5000.f);
            }
            if(g_cfgTargetAction == "No Pvp")
            {
                RPC_SetTeam(np, 2);
            }
            if(g_cfgTargetAction == "Destroy")
            {
                s_field_get_value(np, f_fineRigObj, &_fineRigObj);
                Destroy(runner, _fineRigObj);
            }
        }
    }
}
static void ExecutePlayerAllAction()
{
    if (!GameObject || !NetPlayer || !s_get_method_from_name || !s_runtime_invoke) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: il2cpp not ready");
        return;
    }

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) 
    {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType(Type) not found");
            return;
        }
    }

    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);
    Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
    Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
    Il2CppObject* flareGunType = TypeOf(FlareGun);
    Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
    Il2CppObject* balloonType = TypeOf(Balloon);

    Il2CppException* ex = nullptr;
    void* argsFO[1] = { typeNetPlayer };
    Il2CppObject* arrObj = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFO, &ex);
    if (ex || !arrObj) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType ex=%p arr=%p", ex, arrObj);
        return;
    }

    Il2CppArray* arr = (Il2CppArray*)arrObj;
    if (!arr || arr->max_length == 0) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: no NetPlayer instances");
        return;
    }
    static MethodInfo* m_getDisplayName = nullptr;
    if (!m_getDisplayName) {
        m_getDisplayName = s_get_method_from_name(NetPlayer, "get_displayName", 0);
        if (!m_getDisplayName || !m_getDisplayName->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: get_displayName not found");
            return;
        }
    }

    Il2CppObject** elems = (Il2CppObject**)((char*)arr + sizeof(Il2CppArray));

    auto nm_applyBuff  = s_get_method_from_name(NetPlayer, "RPC_ApplyBuff", 1);
    auto ApplyBuff = (void(*)(Il2CppObject*, int))STRIP_FP(nm_applyBuff->methodPointer);

    MethodInfo* m_AddForce = s_get_method_from_name(NetPlayer, "RPC_AddForce", 1);
    if (!m_AddForce || !m_AddForce->methodPointer) return;
    using t_AddForce = void(*)(Il2CppObject*, Vector3);
    auto AddForce = (t_AddForce)STRIP_FP(m_AddForce->methodPointer);

    auto nm_addMoney  = s_get_method_from_name(NetPlayer, "RPC_AddPlayerMoney", 1);
    auto AddPlayerMoney = (void(*)(Il2CppObject*, int))STRIP_FP(nm_addMoney->methodPointer);

    auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
    auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
    Il2CppObject* nsInstance = get_instance();

    auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
    auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
    Il2CppObject* vr = get_vrPlayer(nsInstance);

    auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
    if (!nm_get_position || !nm_get_position->methodPointer) return;
    auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

    Vector3 camPosition = get_position(nsInstance);

    MethodInfo* m_Teleport = s_get_method_from_name(NetPlayer, "RPC_Teleport", 1);
    if (!m_Teleport || !m_Teleport->methodPointer) return;
    using t_Teleport = void(*)(Il2CppObject*, Vector3);
    auto Teleport = (t_Teleport)STRIP_FP(m_Teleport->methodPointer);

    MethodInfo* m_Muffle = s_get_method_from_name(NetPlayer, "RPC_SetMuffledVoiceEnabled", 1);
    if (!m_Muffle || !m_Muffle->methodPointer) return;
    using t_Muffle = void(*)(Il2CppObject*, bool);
    auto Muffle = (t_Muffle)STRIP_FP(m_Muffle->methodPointer);

    MethodInfo* m_Squeek = s_get_method_from_name(NetPlayer, "RPC_SetSqueakyVoiceEnabled", 1);
    if (!m_Squeek || !m_Squeek->methodPointer) return;
    using t_Squeek = void(*)(Il2CppObject*, bool);
    auto Squeek = (t_Squeek)STRIP_FP(m_Squeek->methodPointer);

    MethodInfo* m_TagAsStinky = s_get_method_from_name(NetPlayer, "RPC_TagAsStinky", 0);
    if (!m_TagAsStinky || !m_TagAsStinky->methodPointer) return;
    using t_TagAsStinky = void(*)(Il2CppObject*);
    auto TagAsStinky = (t_TagAsStinky)STRIP_FP(m_TagAsStinky->methodPointer);

    MethodInfo* m_PlayerHit = s_get_method_from_name(NetPlayer, "RPC_PlayerHit", 3);
    if (!m_PlayerHit || !m_PlayerHit->methodPointer) return;
    using t_PlayerHit = void(*)(Il2CppObject*, int, Vector3, Il2CppObject*);
    auto PlayerHit = (t_PlayerHit)STRIP_FP(m_PlayerHit->methodPointer);

    MethodInfo* m_RoboMonkeItem = s_get_method_from_name(RoboMonkeItem, "RPC_Startup", 1);
    if (!m_RoboMonkeItem || !m_RoboMonkeItem->methodPointer) return;
    using t_RoboMonkeItem = void(*)(Il2CppObject*, PlayerRefNative);
    auto RoboMonkeItem = (t_RoboMonkeItem)STRIP_FP(m_RoboMonkeItem->methodPointer);

    MethodInfo* m_get_objectID = s_get_method_from_name(NetPlayer, "get_objectID", 0);
    if (!m_get_objectID || !m_get_objectID->methodPointer) return;
    using t_get_objectID = int(*)(Il2CppObject*);
    auto get_objectID = (t_get_objectID)STRIP_FP(m_get_objectID->methodPointer);

    MethodInfo* m_get_position = s_get_method_from_name(Transform, "get_position", 0);
    if (!m_get_position || !m_get_position->methodPointer) return;
    using t_get_position = Vector3(*)(Il2CppObject*);
    auto transform_get_position = (t_get_position)STRIP_FP(m_get_position->methodPointer);

    MethodInfo* m_SpawnPickup = s_get_method_from_name(PickupManager, "RPC_SpawnPickup_Internal", 4);
    if (!m_SpawnPickup || !m_SpawnPickup->methodPointer) return;
    using t_SpawnPickup = void(*)(Il2CppObject*, int, Vector3, int);
    auto SpawnPickup = (t_SpawnPickup)STRIP_FP(m_SpawnPickup->methodPointer);

    MethodInfo* m_get_prefab = s_get_method_from_name(RandomPrefab, "get_prefab", 0);
    if (!m_get_prefab || !m_get_prefab->methodPointer) return;
    using t_get_prefab = Il2CppObject*(*)(Il2CppObject*);
    auto get_prefab = (t_get_prefab)STRIP_FP(m_get_prefab->methodPointer);

    MethodInfo* m_RPC_SetJellyEffect = s_get_method_from_name(NetPlayer, "RPC_SetJellyEffect", 2);
    if (!m_RPC_SetJellyEffect || !m_RPC_SetJellyEffect->methodPointer) return;
    using t_RPC_SetJellyEffect = void(*)(Il2CppObject*, float, float);
    auto RPC_SetJellyEffect = (t_RPC_SetJellyEffect)STRIP_FP(m_RPC_SetJellyEffect->methodPointer);

    MethodInfo* m_RPC_ShakeScreen = s_get_method_from_name(NetPlayer, "RPC_ShakeScreen", 5);
    if (!m_RPC_ShakeScreen || !m_RPC_ShakeScreen->methodPointer) return;
    using t_RPC_ShakeScreen = void(*)(Il2CppObject*, float, float, float, float, float);
    auto RPC_ShakeScreen = (t_RPC_ShakeScreen)STRIP_FP(m_RPC_ShakeScreen->methodPointer);

    MethodInfo* m_SetMass = s_get_method_from_name(GrabbableObject, "SetMass", 1);
    if (!m_SetMass || !m_SetMass->methodPointer) return;
    using t_SetMass = void(*)(Il2CppObject*, float);
    auto SetMass = (t_SetMass)STRIP_FP(m_SetMass->methodPointer);

    Il2CppObject* _inflatedBalloonPrefab = nullptr;
    FieldInfo* f_inflatedBalloonPrefab = s_class_get_field_from_name(Balloon, "_inflatedBalloonPrefab");

    Il2CppObject* body = nullptr;
    FieldInfo* fbody = s_class_get_field_from_name(NetPlayer, "body");

    Il2CppObject* _spawnPrefab = nullptr;
    FieldInfo* f_spawnPrefab = s_class_get_field_from_name(NetObjectSpawnGroup, "_spawnPrefab");

    Il2CppObject* _mobPrefab = nullptr;
    FieldInfo* f_mobPrefab = s_class_get_field_from_name(HordeMobController, "_mobPrefab");

    Il2CppObject* _pillowShieldItemPrefab = nullptr;
    FieldInfo* f_pillowShieldItemPrefab = s_class_get_field_from_name(MomBossGameMusicalChair, "_pillowShieldItemPrefab");

    auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
    auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

    for (il2cpp_array_size_t i = 0; i < arr->max_length; ++i) 
    {
        Il2CppObject* np = elems[i];
        if (!np) continue;
        {
            if(g_cfgTargetAction == "Fling")
            {
                AddForce(np, Vector3{0.f, 999.f, 0.f});
            }
            if(g_cfgTargetAction == "Kick")
            {
                Teleport(np, Vector3{-999.f, -99999.f, -999.f});
            }
            if(g_cfgTargetAction == "Kill")
            {
                PlayerHit(np, 938232, Vector3{0.f, 0.f, 0.f,}, nullptr);
            }
             if(g_cfgTargetAction == "Moon Map Tp")
            {
                Teleport(np, Vector3{999.f, 999.f, 999.f});
            }
            if(g_cfgTargetAction == "Add Money")
            {
                AddPlayerMoney(np, 9999999);
            }
            if(g_cfgTargetAction == "Shrink")
            {
                ApplyBuff(np, 10);
            }
            if(g_cfgTargetAction == "Grow")
            {
                ApplyBuff(np, 7);
            }
            if(g_cfgTargetAction == "Stink Jump")
            {
                ApplyBuff(np, 4);
            }
            if(g_cfgTargetAction == "Fart Boost")
            {
                ApplyBuff(np, 11);
            }
            if(g_cfgTargetAction == "Bloodlust")
            {
                ApplyBuff(np, 6);
            }
            if(g_cfgTargetAction == "Big Head")
            {
                ApplyBuff(np, 5);
            }
            if(g_cfgTargetAction == "Flashbang")
            {
                ApplyBuff(np, 13);
            }
            if(g_cfgTargetAction == "Love")
            {
                ApplyBuff(np, 15);
            }
            if(g_cfgTargetAction == "Speedboost")
            {
                ApplyBuff(np, 16);
            }
            if(g_cfgTargetAction == "Cheese Body")
            {
                ApplyBuff(np, 22);
            }
            if(g_cfgTargetAction == "Illness")
            {
                ApplyBuff(np, 23);
            }
            if(g_cfgTargetAction == "Teleport")
            {
                Teleport(np, camPosition);
            }
            if(g_cfgTargetAction == "Muffle Voice")
            {
                Muffle(np, true);
            }
            if(g_cfgTargetAction == "Squeeky Voice")
            {
                Squeek(np, true);
            }
            if(g_cfgTargetAction == "Tag Stinky")
            {
                TagAsStinky(np);
            }
            if(g_cfgTargetAction == "Ammo Giveaway")
            {
                s_field_get_value(np, fbody, &body);
                SpawnPickup(runner, 1, transform_get_position(body), 100);
            }
            if(g_cfgTargetAction == "Nut Giveaway")
            {
                s_field_get_value(np, fbody, &body);
                SpawnPickup(runner, 2, transform_get_position(body), 100);
            }
            if(g_cfgTargetAction == "Robo Monke")
            {
                PlayerRefNative pr;
                if (GetNetPlayerPlayerRef(np, &pr))
                {
                    Il2CppObject* goRobo = SpawnItem(CreateMonoString("item_robo_monke"), GetCamPosition(), -127, 0, 0);

                    Il2CppObject* robo = GO_GetComponentInChildren(goRobo, roboMonkeItemType);

                    CallRoboMonkeStartup(robo, pr);
                }
            }
            if(g_cfgTargetAction == "Gift Car")
            {
                s_field_get_value(np, fbody, &body);
                MethodInfo* m_getName = s_get_method_from_name(GameObject, "get_name", 0);

                Il2CppException* exees = nullptr;
                void* argsFOT[1] = { netObjectSpawnGroupType };
                Il2CppObject* arrPrefabs = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFOT, &exees);
                if (exees || !arrPrefabs) {
                    NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType ex=%p arr=%p", ex, arrObj);
                    return;
                }

                Il2CppArray* arrp = (Il2CppArray*)arrPrefabs;

                Il2CppObject** elemss = (Il2CppObject**)((char*)arrp + sizeof(Il2CppArray));

                for (il2cpp_array_size_t i = 0; i < arrp->max_length; ++i) 
                {
                    Il2CppObject* nosg = elemss[i];
                    if (!nosg) continue;

                    s_field_get_value(nosg, f_spawnPrefab, &_spawnPrefab);

                    Vector3 pos = transform_get_position(body);
                    Quaternion rot{0.f,0.f,0.f,1.f};
                    Il2CppObject* prefab = _spawnPrefab;

                    //CallSpawnGameObject(prefab);
                }
            }
            if(g_cfgTargetAction == "Jellify")
            {
               RPC_SetJellyEffect(np, 50.f, 30.f);
            }
            if(g_cfgTargetAction == "Invisibility")
            {
                RPC_SetJellyEffect(np, 500.f, 500000000.f);
            }
            if(g_cfgTargetAction == "Shake Screen")
            {
                RPC_ShakeScreen(np, 50.f, 2.f, 2.f, 50.f, 50.f);
            }
            if(g_cfgTargetAction == "Shake Screen Insane")
            {
                RPC_ShakeScreen(np, 50.f, 1.f, 1.f, 5000.f, 5000.f);
            }
        }
    }    
}
static void SendPrefabsToAPI()
{
    if (!GameObject || !NetPlayer || !s_get_method_from_name || !s_runtime_invoke) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: il2cpp not ready");
        return;
    }

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) 
    {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
            NSLog(@"[Kitty] FindJeremyAndDoSomething: FindObjectsOfType(Type) not d");
            return;
        }
    }
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* networkObjectPrefabDataType = TypeOf(NetworkObjectPrefabData);

    auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
    auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
    Il2CppObject* nsInstance = get_instance();

    auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
    auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
    Il2CppObject* vr = get_vrPlayer(nsInstance);

    auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
    if (!nm_get_position || !nm_get_position->methodPointer) return;
    auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

    Vector3 camPosition = get_position(nsInstance);

    auto m_get_Config = s_get_method_from_name(NetworkRunner, "get_Config", 0);
            if (!m_get_Config || !m_get_Config->methodPointer) return;
            auto get_Config   = (Il2CppObject*(*)(Il2CppObject*)) STRIP_FP(m_get_Config->methodPointer);
            Il2CppObject* config = get_Config(runner);
            if(config)
            {
                NSLog(@"[Kitty] got config");
            }

            Il2CppObject* prefabTable = nullptr;
            FieldInfo* f_prefabTable = s_class_get_field_from_name(NetworkProjectConfig, "PrefabTable");

            s_field_get_value(config, f_prefabTable, &prefabTable);

            NSLog(@"[Kitty] got and stored prefabtable value");

            auto m_GetId = s_get_method_from_name(NetworkPrefabTable, "GetId", 1);
            if (!m_GetId || !m_GetId->methodPointer) return;
            auto GetId   = (NetworkPrefabId(*)(Il2CppObject*, NetworkObjectGuid)) STRIP_FP(m_GetId->methodPointer);

            NSLog(@"[Kitty] get id stored");

            auto m_Load = s_get_method_from_name(NetworkPrefabTable, "Load", 2);
            if (!m_Load || !m_Load->methodPointer) return;
            auto Load = (Il2CppObject*(*)(Il2CppObject*, NetworkPrefabId, bool)) STRIP_FP(m_Load->methodPointer);

            NSLog(@"[Kitty] load stored");

            auto m_get_gameObject = s_get_method_from_name(Component, "get_gameObject", 0);
            if (!m_get_gameObject || !m_get_gameObject->methodPointer) return;
            auto get_gameObject = (Il2CppObject*(*)(Il2CppObject*)) STRIP_FP(m_get_gameObject->methodPointer);

            MethodInfo* m_getName = s_get_method_from_name(GameObject, "get_name", 0);


            auto m_get_Prefabs = s_get_method_from_name(NetworkPrefabTable, "get_Prefabs", 0);
            using t_get_Prefabs = Il2CppObject* (*)(Il2CppObject*);
            auto get_Prefabs = (t_get_Prefabs)STRIP_FP(m_get_Prefabs->methodPointer);


            Il2CppObject* prefabs = get_Prefabs(prefabTable);

            Il2CppClass* prefabsClass = s_object_get_class(prefabs);

            auto m_get_Count = s_get_method_from_name(prefabsClass, "get_Count", 0);
            using t_get_Count = int32_t (*)(Il2CppObject*);
            auto get_Count = (t_get_Count)STRIP_FP(m_get_Count->methodPointer);

            auto m_get_Item = s_get_method_from_name(prefabsClass, "get_Item", 1);
            using t_get_Item = Il2CppObject* (*)(Il2CppObject*, int32_t);
            auto get_Item = (t_get_Item)STRIP_FP(m_get_Item->methodPointer);

            int32_t count = get_Count(prefabs);

            std::vector<std::string> names;
            names.reserve(count);

            for (int32_t i = 0; i < count; ++i)
            {
                Il2CppObject* src = get_Item(prefabs, i);
                Il2CppClass* srcClass = s_object_get_class(src);

                NetworkObjectGuid assetguidd {};
                FieldInfo* f_assetGuid = s_class_get_field_from_name(srcClass, "AssetGuid");

                s_field_get_value(src, f_assetGuid, &assetguidd);

                NetworkObjectGuid guid = assetguidd;

                NetworkPrefabId prefabId = GetId(prefabTable, guid);

                Il2CppObject* prefabb = Load(prefabTable, prefabId, true);

                Il2CppObject* prefabREAL = get_gameObject(prefabb);

                Il2CppException* ex = nullptr;
                Il2CppObject* nameObj = s_runtime_invoke(m_getName, prefabREAL, nullptr, &ex);

                Il2CppString* s = (Il2CppString*)nameObj;
                std::string name = il2cpp_string_to_std(s, string_chars, string_length);

                if (!name.empty())
                {
                    names.push_back(name);
                }

                if (names.empty()) {
                    NSLog(@"[Kitty] SendNetPlayersToAPI: no display names collected");
                    return;
                }

                NSLog(@"[Kitty] SendNetPlayersToAPI: collected %u player(s)", (unsigned)names.size());

                NSMutableArray<NSString*> *playerList = [NSMutableArray arrayWithCapacity:names.size()];
                for (auto &n : names) 
                {
                    [playerList addObject:[NSString stringWithUTF8String:n.c_str()]];
                }

                NSDictionary *bodyDict = @{ @"prefabs": playerList };

                NSError *encodeErr = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict
                                                                options:0
                                                                    error:&encodeErr];
                if (!jsonData || encodeErr) {
                    NSLog(@"[Kitty] SendNetPlayersToAPI: JSON encode error=%@", encodeErr);
                    return;
                }

                NSURL *url = [NSURL URLWithString:@"https://acapiforapk.onrender.com/api/prefabs"];
                if (!url) 
                {
                    NSLog(@"[Kitty] SendNetPlayersToAPI: invalid URL");
                    return;
                }

                NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
                req.HTTPMethod = @"POST";
                [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                req.HTTPBody = jsonData;

                NSURLSessionDataTask *task =
                [[NSURLSession sharedSession] dataTaskWithRequest:req
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error)
                {
                    if (error) {
                        NSLog(@"[Kitty] SendNetPlayersToAPI: POST error=%@", error);
                        return;
                    }
                    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                    NSLog(@"[Kitty] SendNetPlayersToAPI: POST /api/prefabs status %ld",
                        (long)http.statusCode);
                }];

                [task resume];
            }
}
static void PrefabSpammer()
{
    if(!doneprefabspam)
    {
        if(!doneFetchingPrefabs)
        {
            SendPrefabsToAPI();
            doneFetchingPrefabs = true;
        }

        if (!GameObject || !NetPlayer || !s_get_method_from_name || !s_runtime_invoke) {
        NSLog(@"[Kitty] FindJeremyAndDoSomething: il2cpp not ready");
        return;
        }

        static MethodInfo* m_FindObjectsOfType = nullptr;
        if (!m_FindObjectsOfType) 
        {
            m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
            if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) {
                NSLog(@"[Kitty] FindJeremyAndDoSomething:  FindObjectsOfType(Type) not found");
                return;
            }
        }

        Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
        Il2CppObject* trampolineType = TypeOf(Trampoline);
        Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
        Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
        Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
        Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
        Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
        Il2CppObject* gameObjectType = TypeOf(GameObject);
        Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
        Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
        Il2CppObject* backpackType    = TypeOf(BackpackItem);
        Il2CppObject* grabbableObjectType    = TypeOf(GrabbableObject);
        Il2CppObject* quiverType    = TypeOf(Quiver);
        Il2CppObject* pickupManagerType = TypeOf(PickupManager);
        Il2CppObject* grabbableType = TypeOf(GrabbableItem);
        Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
        Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
        Il2CppObject* flareGunType = TypeOf(FlareGun);
        Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
        Il2CppObject* balloonType = TypeOf(Balloon);
        Il2CppObject* networkObjectPrefabDataType = TypeOf(NetworkObjectPrefabData);

        auto nm_f_instance  = s_get_method_from_name(NetSpectator, "get_localInstance", 0);
        auto get_instance   = (Il2CppObject*(*)())STRIP_FP(nm_f_instance->methodPointer);
        Il2CppObject* nsInstance = get_instance();

        auto nm_vrPlayer  = s_get_method_from_name(NetSpectator, "get_associatedVRPlayer", 0);
        auto get_vrPlayer = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_vrPlayer->methodPointer);
        Il2CppObject* vr = get_vrPlayer(nsInstance);

        auto nm_get_position = s_get_method_from_name(NetSpectator, "get_position", 0);
        if (!nm_get_position || !nm_get_position->methodPointer) return;
        auto get_position   = (Vector3(*)(Il2CppObject*)) STRIP_FP(nm_get_position->methodPointer);

        Vector3 camPosition = get_position(nsInstance);

        MethodInfo* spawn_GO = FindSpawnItemGO(NetworkRunner);
        if (!spawn_GO || !spawn_GO->methodPointer) return;

        auto m_get_Config = s_get_method_from_name(NetworkRunner, "get_Config", 0);
        if (!m_get_Config || !m_get_Config->methodPointer) return;
        auto get_Config   = (Il2CppObject*(*)(Il2CppObject*)) STRIP_FP(m_get_Config->methodPointer);
        Il2CppObject* config = get_Config(runner);

        Il2CppObject* prefabTable = nullptr;
        FieldInfo* f_prefabTable = s_class_get_field_from_name(NetworkProjectConfig, "PrefabTable");

        s_field_get_value(config, f_prefabTable, &prefabTable);


        auto m_GetId = s_get_method_from_name(NetworkPrefabTable, "GetId", 1);
        if (!m_GetId || !m_GetId->methodPointer) return;
        auto GetId   = (NetworkPrefabId(*)(Il2CppObject*, NetworkObjectGuid)) STRIP_FP(m_GetId->methodPointer);

        auto m_Load = s_get_method_from_name(NetworkPrefabTable, "Load", 2);
        if (!m_Load || !m_Load->methodPointer) return;
        auto Load = (Il2CppObject*(*)(Il2CppObject*, NetworkPrefabId, bool)) STRIP_FP(m_Load->methodPointer);

        auto m_get_gameObject = s_get_method_from_name(Component, "get_gameObject", 0);
        if (!m_get_gameObject || !m_get_gameObject->methodPointer) return;
        auto get_gameObject = (Il2CppObject*(*)(Il2CppObject*)) STRIP_FP(m_get_gameObject->methodPointer);

        MethodInfo* m_getName = s_get_method_from_name(GameObject, "get_name", 0);

        auto m_get_Prefabs = s_get_method_from_name(NetworkPrefabTable, "get_Prefabs", 0);
        using t_get_Prefabs = Il2CppObject* (*)(Il2CppObject*);
        auto get_Prefabs = (t_get_Prefabs)STRIP_FP(m_get_Prefabs->methodPointer);


        Il2CppObject* prefabs = get_Prefabs(prefabTable);

        Il2CppClass* prefabsClass = s_object_get_class(prefabs);

        auto m_get_Count = s_get_method_from_name(prefabsClass, "get_Count", 0);
        using t_get_Count = int32_t (*)(Il2CppObject*);
        auto get_Count = (t_get_Count)STRIP_FP(m_get_Count->methodPointer);

        auto m_get_Item = s_get_method_from_name(prefabsClass, "get_Item", 1);
        using t_get_Item = Il2CppObject* (*)(Il2CppObject*, int32_t);
        auto get_Item = (t_get_Item)STRIP_FP(m_get_Item->methodPointer);

        int32_t count = get_Count(prefabs);

        for (int32_t i = 0; i < count; ++i)
        {
            Il2CppObject* src = get_Item(prefabs, i);
            Il2CppClass* srcClass = s_object_get_class(src);

            NetworkObjectGuid assetguidd {};
            FieldInfo* f_assetGuid = s_class_get_field_from_name(srcClass, "AssetGuid");

            s_field_get_value(src, f_assetGuid, &assetguidd);

            NetworkObjectGuid guid = assetguidd;

            NetworkPrefabId prefabId = GetId(prefabTable, guid);

            Il2CppObject* prefabb = Load(prefabTable, prefabId, true);

            Il2CppObject* prefabREAL = get_gameObject(prefabb);

            Il2CppException* ex = nullptr;
            Il2CppObject* nameObj = s_runtime_invoke(m_getName, prefabREAL, nullptr, &ex);

            Il2CppString* s = (Il2CppString*)nameObj;
            std::string n = il2cpp_string_to_std(s, string_chars, string_length);
            if(g_cfgPrefabId == n)
            {
                System_Nullable_1_UnityEngine_Vector3_ nPos{};
                nPos.has_value = true;
                nPos.value     = camPosition;


                Quaternion rot{0.f, 0.f, 0.f, 1.f};
                System_Nullable_1_UnityEngine_Quaternion_ nRot{};
                nRot.has_value = true;
                nRot.value     = rot;


                System_Nullable_1_Fusion_PlayerRef_ nPlayer{};
                nPlayer.has_value = false;     

                Il2CppObject* onBeforeSpawned = nullptr;
                int32_t flags = 0;  

                Il2CppObject* prefab = prefabREAL;
                void* args[6] = {
                    prefab,
                    &nPos,
                    &nRot,
                    &nPlayer,
                    onBeforeSpawned,
                    &flags
                };
                Il2CppException* exps = nullptr;
                Il2CppObject* spawned = s_runtime_invoke(spawn_GO, runner, args, &exps);
            }
        }
        doneprefabspam = true;
    }
}
static std::string ToStdString(Il2CppString* s) {
    return il2cpp_string_to_std(s, string_chars, string_length);
}
static std::string ObjToString(Il2CppObject* o) {
    if (!o || !s_object_get_class || !s_get_method_from_name || !s_runtime_invoke)
        return {};
    Il2CppClass* k = s_object_get_class(o);
    if (!k) return {};
    MethodInfo* m = s_get_method_from_name(k, "ToString", 0);
    if (!m || !m->methodPointer) return {};
    Il2CppException* ex = nullptr;
    auto str = (Il2CppString*)s_runtime_invoke(m, o, nullptr, &ex);
    if (ex || !str) return {};
    return ToStdString(str);
}
static void InitHooks()
{
}
static void SpawnCrossbowTowersIntoBag(Il2CppObject* quiver, int ammount)
{
    if(!Crossbow || !NetworkBehaviour)
    {
        Crossbow = classMap["AnimalCompany"]["Crossbow"];
        NetworkBehaviour = classMap["Fusion"]["NetworkBehaviour"];
    }

    auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
    auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

    Il2CppObject* grabbableType = TypeOf(GrabbableObject);
    Il2CppObject* crossbowType  = TypeOf(Crossbow);

    MethodInfo* m_TryGrabObject = s_get_method_from_name(AttachedItemAnchor, "TryGrabObject", 4);
    if(!m_TryGrabObject || !m_TryGrabObject->methodPointer) return;
    using t_TryGrabObject = void(*)(Il2CppObject*, NetworkBehaviourId, bool, bool, bool);
    auto TryGrabObject = (t_TryGrabObject)STRIP_FP(m_TryGrabObject->methodPointer);

    MethodInfo* m_get_Id = s_get_method_from_name(NetworkBehaviour, "get_Id", 0);
    if(!m_get_Id || !m_get_Id->methodPointer) return;
    using t_get_Id = NetworkBehaviourId(*)(Il2CppObject*);
    auto get_Id = (t_get_Id)STRIP_FP(m_get_Id->methodPointer);

    FieldInfo* f_attachAnchor = s_class_get_field_from_name(Crossbow, "_attachAnchor");

    for(int tower = 0; tower < ammount; tower++)
    {
        Il2CppObject* goBase = SpawnItem(CreateMonoString("item_crossbow"),
                                         GetCamPosition(),0,0,0);

        Il2CppObject* baseCrossbow = GO_GetComponentInChildren(goBase, crossbowType);
        if(!baseCrossbow) continue;

        Il2CppObject* baseGrabbable = GO_GetComponentInChildren(goBase, grabbableType);
        if(!baseGrabbable) continue;

        Il2CppObject* currentAnchor = nullptr;
        s_field_get_value(baseCrossbow, f_attachAnchor, &currentAnchor);
        if(!currentAnchor) continue;

        for(int i = 0; i < 6; i++)
        {
            Il2CppObject* goNext = SpawnItem(CreateMonoString("item_crossbow"),
                                             GetCamPosition(),0,0,0);

            Il2CppObject* nextGrabbable = GO_GetComponentInChildren(goNext, grabbableType);
            if(!nextGrabbable) continue;

            NetworkBehaviourId nextId = get_Id(nextGrabbable);

            TryGrabObject(currentAnchor, nextId, false, true, false);

            Il2CppObject* nextCrossbow = GO_GetComponentInChildren(goNext, crossbowType);
            if(!nextCrossbow) break;

            Il2CppObject* nextAnchor = nullptr;
            s_field_get_value(nextCrossbow, f_attachAnchor, &nextAnchor);
            if(!nextAnchor) break;

            currentAnchor = nextAnchor;
        }
        //bool res = TryAddItem(quiver, baseGrabbable);
        //NSLog(@"[Kitty] Added Xbow Tower %d -> %d", tower, (int)res);
    }
}
static void CrossbowChildren()
{
    if(!CrossbowsDone)
    {
        Il2CppObject* backpackType    = TypeOf(BackpackItem);
        Il2CppObject* quiverType    = TypeOf(Quiver);
        Il2CppObject* grabbableType = TypeOf(GrabbableItem);

        Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_backpack_large_basketball"), GetCamPosition(), (int8_t)0, (int8_t)0, (uint8_t)0);
        
        Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, backpackType);
        SpawnCrossbowTowersIntoBag(quiver, 23);

        CrossbowsDone = true;
    }
}
static void SetGLNetId(Il2CppObject* quiverInstance, short newNetId)
{
    if (!quiverInstance || !Quiver) {
        NSLog(@"[Kitty] InitializeQuiverNetId: no quiver / class");
        return;
    }

    static MethodInfo* m_getContained = nullptr;
    if (!m_getContained) {
        m_getContained = s_get_method_from_name(GrenadeLauncher, "get_containedObjects", 0);
        if (!m_getContained || !m_getContained->methodPointer) {
            NSLog(@"[Kitty] InitializeQuiverNetId: get_containedObjects not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* boxedList = s_runtime_invoke(m_getContained, quiverInstance, nullptr, &ex);
    if (ex || !boxedList) {
        NSLog(@"[Kitty] InitializeQuiverNetId: get_containedObjects failed ex=%p list=%p", ex, boxedList);
        return;
    }

    void* listThis = (void*)((char*)boxedList + sizeof(Il2CppObject));

    static MethodInfo* m_getCount = nullptr;
    static MethodInfo* m_getItem  = nullptr;
    static MethodInfo* m_setItem  = nullptr;

    if (!m_getCount || !m_getItem || !m_setItem) {
        Il2CppClass* listClass = s_object_get_class(boxedList);
        if (!listClass) {
            NSLog(@"[Kitty] InitializeQuiverNetId: listClass NULL");
            return;
        }

        m_getCount = s_get_method_from_name(listClass, "get_Count", 0);
        m_getItem  = s_get_method_from_name(listClass, "get_Item", 1);
        m_setItem  = s_get_method_from_name(listClass, "Set",      2);
        if (!m_setItem)
            m_setItem = s_get_method_from_name(listClass, "set_Item", 2);

        if (!m_getCount || !m_getItem || !m_setItem ||
            !m_getCount->methodPointer || !m_getItem->methodPointer || !m_setItem->methodPointer)
        {
            NSLog(@"[Kitty] InitializeQuiverNetId: list methods missing");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* boxedCount = s_runtime_invoke(m_getCount, listThis, nullptr, &ex);
    if (ex || !boxedCount) {
        NSLog(@"[Kitty] InitializeQuiverNetId: get_Count failed ex=%p countObj=%p", ex, boxedCount);
        return;
    }

    int count = *(int*)((char*)boxedCount + sizeof(Il2CppObject));
    if (count <= 0) {
        NSLog(@"[Kitty] InitializeQuiverNetId: list empty (count=%d)", count);
        return;
    }

    NSLog(@"[Kitty] InitializeQuiverNetId: count=%d, newNetId=%d", count, (int)newNetId);

    for (int i = 0; i < count; ++i) {
        void* argsIdx[1] = { &i };
        ex = nullptr;
        Il2CppObject* boxedElem = s_runtime_invoke(m_getItem, listThis, argsIdx, &ex);
        if (ex || !boxedElem) {
            NSLog(@"[Kitty] InitializeQuiverNetId: get_Item(%d) failed ex=%p elem=%p", i, ex, boxedElem);
            continue;
        }

        char* elemValPtr = (char*)boxedElem + sizeof(Il2CppObject);

        uint8_t buf[kContainedItemCoreDataSize];
        memcpy(buf, elemValPtr, kContainedItemCoreDataSize);

        short* netIdPtr = (short*)(buf + 0x04);
        *netIdPtr = newNetId;

        void* argsSet[2] = { &i, buf };
        ex = nullptr;
        s_runtime_invoke(m_setItem, listThis, argsSet, &ex);
        if (ex) {
            NSLog(@"[Kitty] InitializeQuiverNetId: Set[%d] threw ex=%p", i, ex);
            continue;
        }

        NSLog(@"[Kitty] InitializeQuiverNetId: slot %d netID set to %d", i, (int)*netIdPtr);
    }

    NSLog(@"[Kitty] InitializeQuiverNetId: done");
}
static void SpawnGrenadeLauncherWithContents()
{
     if (!PrefabGenerator || !GrabbableItem || !BackpackItem || !GameObject ||
            !g_SpawnItem || !GO_GetComponentInChildren || !s_get_method_from_name || !s_runtime_invoke)
            {
                NSLog(@"[Kitty] SpawnBanana: required il2cpp symbols/classes missing");
                return;
            }

            auto mComp_getGO = s_get_method_from_name(Component,       "get_gameObject",      0);
            auto mSetScale   = s_get_method_from_name(GrabbableObject, "set_scaleModifier",   1);
            auto mSetSat     = s_get_method_from_name(GrabbableObject, "set_colorSaturation", 1);
            auto mSetHue     = s_get_method_from_name(GrabbableObject, "set_colorHue",        1);

            Il2CppObject* grItemType = nullptr;
            if (s_type_get_object && GrabbableItem)
                grItemType = s_type_get_object(&GrabbableItem->byval_arg);

            std::vector<ChildSpec> children;
            {
                std::lock_guard<std::mutex> lk(g_cfgMd);
                children = g_cfgChildren;
            }

            Il2CppObject* backpackType    = TypeOf(BackpackItem);
            Il2CppObject* quiverType    = TypeOf(Quiver);
            Il2CppObject* grabbableType = TypeOf(GrabbableItem);
            Il2CppObject* glType = TypeOf(GrenadeLauncher);

            auto m_TryAddItem = s_get_method_from_name(GrenadeLauncher, "CheckToAddItem", 1);
            if (!m_TryAddItem || !m_TryAddItem->methodPointer) {
                NSLog(@"[Kitty] SpawnBanana: BackpackItem.TryAddItem not found");
                return;
            }
            auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

            uint8_t hueB = clamp_u8((float)g_cfgQHue.load());
            int8_t satSb = clamp_i8((float)g_cfgQSat.load());
            int8_t scaleB = clamp_i8((float)g_cfgQScale.load());

            Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_grenade_launcher"), GetCamPosition(), (int8_t)scaleB, (int8_t)satSb, (uint8_t)hueB);
            if (!goQuiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: failed to spawn quiver");
                return;
            }

            Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, glType);
            if (!quiver) 
            {
                NSLog(@"[Kitty] SpawnBanana: quiver not found on spawned object");
                return;
            }

            for (const ChildSpec& cs : children)
            {
                NSLog(@"[Kitty] child itemId=%s ammo=%d hue=%d sat=%d scale=%d", cs.itemId.c_str(), cs.ammo, cs.colorHue, cs.colorSat, cs.scale);

                if (cs.itemId.empty()) {
                    continue;
                }

                std::string fullPath = "" + cs.itemId;
                Il2CppString* prefabName = CreateMonoString(fullPath.c_str());

                Il2CppObject* goItem = SpawnItem(prefabName, GetCamPosition(), (int8_t)cs.scale, (int8_t)cs.colorSat, (uint8_t)cs.colorHue);

                Il2CppObject* grabbable = GO_GetComponentInChildren(goItem, grabbableType);

                SetEquippingConfig(grabbable);

                bool ok = TryAddItem(quiver, grabbable);

                if(g_netId.load() != -1)
                {
                    SetGLNetId(quiver, g_netId.load());
                }
                NSLog(@"[Kitty] CheckToAddItem -> %d for %s", (int)ok, fullPath.c_str());
            }
}
static void AddToBag(Il2CppObject* grabbable)
{
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);

    auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
    auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

    Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_backpack_large_base"), GetCamPosition(), (int8_t)0, (int8_t)0, (uint8_t)0);
    Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, backpackType);

    TryAddItem(quiver, grabbable);
}
static void CrossbowModded()
{
    if(!Crossbow || !GameplayItemState)
    {
        Crossbow = classMap["AnimalCompany"]["Crossbow"];
        GameplayItemState = classMap["AnimalCompany"]["GameplayItemState"];
    }

    Il2CppObject* grabbableItemType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableType = TypeOf(GrabbableObject);
    Il2CppObject* crossbowType = TypeOf(Crossbow);
    Il2CppObject* netBehaviourType = TypeOf(NetworkBehaviour);

    Il2CppObject* goCrossbow = SpawnItem(CreateMonoString("item_crossbow"), GetCamPosition(), 0, 0, 0);
    Il2CppObject* crossb = GO_GetComponentInChildren(goCrossbow, crossbowType);
    Il2CppObject* crossgit = GO_GetComponentInChildren(goCrossbow, grabbableItemType);

    Il2CppObject* goStick = SpawnItem(CreateMonoString("item_treestick"), GetCamPosition(), 0, 0, 0);
    Il2CppObject* stick = GO_GetComponentInChildren(goStick, grabbableType);
    Il2CppObject* stickitemtype = GO_GetComponentInChildren(goStick, grabbableItemType);

    Il2CppObject* _attachAnchor = nullptr;
    FieldInfo* f_attachAnchor = s_class_get_field_from_name(Crossbow, "_attachAnchor");
    s_field_get_value(crossb, f_attachAnchor, &_attachAnchor);

    MethodInfo* m_TryGrabObject = s_get_method_from_name(AttachedItemAnchor, "TryGrabObject", 4);
    using t_TryGrabObject = void(*)(Il2CppObject*, NetworkBehaviourId, bool, bool, bool);
    auto TryGrabObject = (t_TryGrabObject)STRIP_FP(m_TryGrabObject->methodPointer);

    MethodInfo* m_get_Id = s_get_method_from_name(NetworkBehaviour, "get_Id", 0);
    using t_get_Id = NetworkBehaviourId(*)(Il2CppObject*);
    auto get_Id = (t_get_Id)STRIP_FP(m_get_Id->methodPointer);

    MethodInfo* m_set_id = s_get_method_from_name(GameplayItemState, "set_id", 1);
    using t_set_id = void(*)(Il2CppObject*, Il2CppString*);
    auto set_id = (t_set_id)STRIP_FP(m_set_id->methodPointer);
    
    Il2CppObject* _itemData = nullptr;
    FieldInfo* f_itemData = s_class_get_field_from_name(GrabbableItem, "_itemData");
    s_field_get_value(stickitemtype, f_itemData, &_itemData);

    set_id(_itemData, CreateMonoString(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DANT"));

    NetworkBehaviourId netBId = get_Id(stick);
    TryGrabObject(_attachAnchor, netBId, false, true, false);

    AddToBag(crossgit);
}
static void PatchAppState()
{
    if (!App || !s_get_method_from_name || !s_runtime_invoke || !s_object_get_class) {
        NSLog(@"[Kitty] AppState: missing il2cpp symbols/classes");
        return;
    }

    // App.state (static)
    static MethodInfo* m_App_get_state = nullptr;
    if (!m_App_get_state) {
        m_App_get_state = s_get_method_from_name(App, "get_state", 0);
        if (!m_App_get_state || !m_App_get_state->methodPointer) {
            NSLog(@"[Kitty] AppState: App.get_state not found");
            return;
        }
    }

    Il2CppException* ex = nullptr;
    Il2CppObject* appState = s_runtime_invoke(m_App_get_state, nullptr, nullptr, &ex);
    if (ex || !appState) {
        NSLog(@"[Kitty] AppState: get_state ex=%p state=%p", ex, appState);
        return;
    }
    NSLog(@"[Kitty] AppState=%p", appState);

    // AppState.user
    Il2CppClass* appStateCls = s_object_get_class(appState);
    static MethodInfo* m_AppState_get_user = nullptr;
    if (!m_AppState_get_user) {
        m_AppState_get_user = s_get_method_from_name(appStateCls, "get_user", 0);
        if (!m_AppState_get_user || !m_AppState_get_user->methodPointer) {
            NSLog(@"[Kitty] AppState: get_user not found");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* userState = s_runtime_invoke(m_AppState_get_user, appState, nullptr, &ex);
    if (ex || !userState) {
        NSLog(@"[Kitty] AppState: get_user ex=%p user=%p", ex, userState);
        return;
    }
    NSLog(@"[Kitty] UserState=%p", userState);

    // UserState.isDeveloper (StatePrimitive<bool>)
    Il2CppClass* userCls = s_object_get_class(userState);
    static MethodInfo* m_User_get_isDev = nullptr;
    if (!m_User_get_isDev) {
        m_User_get_isDev = s_get_method_from_name(userCls, "get_isDeveloper", 0);
        if (!m_User_get_isDev || !m_User_get_isDev->methodPointer) {
            NSLog(@"[Kitty] UserState: get_isDeveloper not found");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* isDevSP = s_runtime_invoke(m_User_get_isDev, userState, nullptr, &ex);
    if (ex || !isDevSP) {
        NSLog(@"[Kitty] UserState: get_isDeveloper ex=%p sp=%p", ex, isDevSP);
        return;
    }
    NSLog(@"[Kitty] StatePrimitive<bool>=%p", isDevSP);

    Il2CppClass* spBoolCls = s_object_get_class(isDevSP);
    MethodInfo* m_SPBool_set_value = s_get_method_from_name(spBoolCls, "set_value", 1);
    if (!m_SPBool_set_value) m_SPBool_set_value = s_get_method_from_name(spBoolCls, "SetValue", 1);
    if (!m_SPBool_set_value || !m_SPBool_set_value->methodPointer) {
        NSLog(@"[Kitty] StatePrimitive<bool>: setter missing");
    } else {
        bool bTrue = true;
        void* argsBool[1] = { &bTrue };
        ex = nullptr;
        s_runtime_invoke(m_SPBool_set_value, isDevSP, argsBool, &ex);
        if (ex) NSLog(@"[Kitty] StatePrimitive<bool>: set_value ex=%p", ex);
        else    NSLog(@"[Kitty] isDeveloper set to TRUE");
    }

    // UserState.wallet
    static MethodInfo* m_User_get_wallet = nullptr;
    if (!m_User_get_wallet) {
        m_User_get_wallet = s_get_method_from_name(userCls, "get_wallet", 0);
        if (!m_User_get_wallet || !m_User_get_wallet->methodPointer) {
            NSLog(@"[Kitty] UserState: get_wallet not found");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* walletState = s_runtime_invoke(m_User_get_wallet, userState, nullptr, &ex);
    if (ex || !walletState) {
        NSLog(@"[Kitty] UserState: get_wallet ex=%p wallet=%p", ex, walletState);
        return;
    }
    NSLog(@"[Kitty] UserWalletState=%p", walletState);

    // UserWalletState.softCurrency (StatePrimitive<long>)
    Il2CppClass* walletCls = s_object_get_class(walletState);
    static MethodInfo* m_Wallet_get_soft = nullptr;
    if (!m_Wallet_get_soft) {
        m_Wallet_get_soft = s_get_method_from_name(walletCls, "get_softCurrency", 0);
        if (!m_Wallet_get_soft || !m_Wallet_get_soft->methodPointer) {
            NSLog(@"[Kitty] Wallet: get_softCurrency not found");
            return;
        }
    }

    ex = nullptr;
    Il2CppObject* softSP = s_runtime_invoke(m_Wallet_get_soft, walletState, nullptr, &ex);
    if (ex || !softSP) {
        NSLog(@"[Kitty] Wallet: get_softCurrency ex=%p sp=%p", ex, softSP);
        return;
    }
    NSLog(@"[Kitty] StatePrimitive<long>=%p", softSP);

    Il2CppClass* spLongCls = s_object_get_class(softSP);
    MethodInfo* m_SPLong_set_value = s_get_method_from_name(spLongCls, "set_value", 1);
    if (!m_SPLong_set_value) m_SPLong_set_value = s_get_method_from_name(spLongCls, "SetValue", 1);
    if (!m_SPLong_set_value || !m_SPLong_set_value->methodPointer) {
        NSLog(@"[Kitty] StatePrimitive<long>: setter missing");
    } else {
        long zero = 0;
        void* argsLong[1] = { &zero };
        ex = nullptr;
        s_runtime_invoke(m_SPLong_set_value, softSP, argsLong, &ex);
        if (ex) NSLog(@"[Kitty] StatePrimitive<long>: set_value ex=%p", ex);
        else    NSLog(@"[Kitty] softCurrency set to 0");
    }
}
static void UpdateWalletSoftCurrency()
{
    if (!AnimalCompanyAPI || !s_get_method_from_name || !s_runtime_invoke || !s_object_get_class) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: missing il2cpp symbols/classes");
        return;
    }

   NSLog(@"[Kitty] None of refs null");

    MethodInfo* m_get_instance = s_get_method_from_name(AnimalCompanyAPI, "get_instance", 0);
    if (!m_get_instance || !m_get_instance->methodPointer) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: get_instance not found");
        return;
    }

    NSLog(@"[Kitty] stored api instance");   

    Il2CppException* ex = nullptr;
    Il2CppObject* apiInstance = s_runtime_invoke(m_get_instance, nullptr, nullptr, &ex);
    if (ex || !apiInstance) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: get_instance ex=%p inst=%p", ex, apiInstance);
        return;
    }

    NSLog(@"[Kitty] invoked api instance so we can use it");   

    MethodInfo* m_get_session = s_get_method_from_name(AnimalCompanyAPI, "get_session", 0);
    if (!m_get_session || !m_get_session->methodPointer) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: get_session not found");
        return;
    }

    NSLog(@"[Kitty] stored session ref");   

    ex = nullptr;
    Il2CppObject* sessionObj = s_runtime_invoke(m_get_session, apiInstance, nullptr, &ex);
    if (ex || !sessionObj) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: get_session ex=%p sess=%p", ex, sessionObj);
        return;
    }


    NSLog(@"[Kitty] invoked session ref so we can use it");   

    MethodInfo* m_UpdateWalletSoftCurrencyAsync = s_get_method_from_name(AnimalCompanyAPI, "UpdateWalletSoftCurrencyAsync", 3);
    if (!m_UpdateWalletSoftCurrencyAsync || !m_UpdateWalletSoftCurrencyAsync->methodPointer) {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: UpdateWalletSoftCurrencyAsync not found");
        return;
    }

    NSLog(@"[Kitty] stored updatecurrency void");   

    long amount = 0;
    void* argsAsync[3] = { sessionObj, &amount, nullptr };
    ex = nullptr;
    Il2CppObject* taskObj = s_runtime_invoke(m_UpdateWalletSoftCurrencyAsync, apiInstance, argsAsync, &ex);

    
    NSLog(@"[Kitty] invoked updatecurrency lets see if we got errors");   

    if (ex || !taskObj) 
    {
        NSLog(@"[Kitty] UpdateWalletSoftCurrency: Async call ex=%p task=%p", ex, taskObj);
        return;
    }
    NSLog(@"[Kitty] got Task<IApiRpc>=%p", taskObj);

    Il2CppClass* taskCls = s_object_get_class(taskObj);
    
    NSLog(@"[Kitty] stored task class");   

    MethodInfo* m_GetAwaiter = s_get_method_from_name(taskCls, "GetAwaiter", 0);
    if (!m_GetAwaiter || !m_GetAwaiter->methodPointer) {
        NSLog(@"[Kitty] Task.GetAwaiter not found");
        return;
    }
    
    NSLog(@"[Kitty] stored get awaiter method");   

    ex = nullptr;
    Il2CppObject* awaiterBoxed = s_runtime_invoke(m_GetAwaiter, taskObj, nullptr, &ex);
    if (ex || !awaiterBoxed) {
        NSLog(@"[Kitty] GetAwaiter ex=%p aw=%p", ex, awaiterBoxed);
        return;
    }


    NSLog(@"[Kitty] invoked getawaiter");   

    void* awaiterThis = (void*)((char*)awaiterBoxed + sizeof(Il2CppObject));
    Il2CppClass* awaiterCls = s_object_get_class(awaiterBoxed);
    
    NSLog(@"[Kitty] boxing value");   

    MethodInfo* m_GetResult = s_get_method_from_name(awaiterCls, "GetResult", 0);
    if (!m_GetResult || !m_GetResult->methodPointer) {
        NSLog(@"[Kitty] TaskAwaiter.GetResult not found");
        return;
    }

    NSLog(@"[Kitty] boxed value");   

    ex = nullptr;
    Il2CppObject* rpcResult = s_runtime_invoke(m_GetResult, awaiterThis, nullptr, &ex);
    if (ex) {
        NSLog(@"[Kitty] GetResult ex=%p", ex);
        return;
    }
    NSLog(@"[Kitty] UpdateWalletSoftCurrencyAsync completed, IApiRpc=%p", rpcResult);
}
static void SpawnHeavyStick()
{
    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);
    Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
    Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
    Il2CppObject* flareGunType = TypeOf(FlareGun);
    Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
    Il2CppObject* balloonType = TypeOf(Balloon);
    Il2CppObject* stashType = TypeOf(UserStashAndLoadoutSaveMediator);

    MethodInfo* m_SetMass = s_get_method_from_name(GrabbableObject, "SetMass", 1);
    if (!m_SetMass || !m_SetMass->methodPointer) return;
    using t_SetMass = void(*)(Il2CppObject*, float);
    auto SetMass = (t_SetMass)STRIP_FP(m_SetMass->methodPointer);

    UpdateWalletSoftCurrency();

    Il2CppObject* goCrossbow = SpawnItem(CreateMonoString("item_treestick"), GetCamPosition(), 0, 0, 0);
    Il2CppObject* stash = GO_AddComponent(goCrossbow, stashType);

    Il2CppObject* crossb = GO_GetComponentInChildren(goCrossbow, grabbableObjectType);
    SetMass(crossb, 50000.f);
}

static void SpawnValuableStick()
{
    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);
    Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
    Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
    Il2CppObject* flareGunType = TypeOf(FlareGun);
    Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
    Il2CppObject* balloonType = TypeOf(Balloon);

    MethodInfo* m_RPC_SetAdditionalSellValue = s_get_method_from_name(GrabbableItem, "RPC_SetAdditionalSellValue", 1);
    if (!m_RPC_SetAdditionalSellValue || !m_RPC_SetAdditionalSellValue->methodPointer) return;
    using t_RPC_SetAdditionalSellValue = void(*)(Il2CppObject*, int);
    auto RPC_SetAdditionalSellValue = (t_RPC_SetAdditionalSellValue)STRIP_FP(m_RPC_SetAdditionalSellValue->methodPointer);

    Il2CppObject* goCrossbow = SpawnItem(CreateMonoString("item_treestick"), GetCamPosition(), 0, 0, 0);
    Il2CppObject* crossb = GO_GetComponentInChildren(goCrossbow, grabbableObjectType);
    RPC_SetAdditionalSellValue(crossb, 300000);
}
static void SpawnStackedCrossbow()
{
    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);
    Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
    Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
    Il2CppObject* flareGunType = TypeOf(FlareGun);
    Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
    Il2CppObject* balloonType = TypeOf(Balloon);
    Il2CppObject* crossbowType = TypeOf(Crossbow);

    MethodInfo* m_TryGrabObject = s_get_method_from_name(AttachedItemAnchor, "TryGrabObject", 4);
    if(!m_TryGrabObject || !m_TryGrabObject->methodPointer) return;
    using t_TryGrabObject = void(*)(Il2CppObject*, NetworkBehaviourId, bool, bool, bool);
    auto TryGrabObject = (t_TryGrabObject)STRIP_FP(m_TryGrabObject->methodPointer);

    MethodInfo* m_get_Id = s_get_method_from_name(NetworkBehaviour, "get_Id", 0);
    if(!m_get_Id || !m_get_Id->methodPointer) return;
    using t_get_Id = NetworkBehaviourId(*)(Il2CppObject*);
    auto get_Id = (t_get_Id)STRIP_FP(m_get_Id->methodPointer);

    FieldInfo* f_attachAnchor = s_class_get_field_from_name(Crossbow, "_attachAnchor");    

    Il2CppObject* goBase = SpawnItem(CreateMonoString("item_crossbow"),
                                         GetCamPosition(),0,0,0);

    Il2CppObject* baseCrossbow = GO_GetComponentInChildren(goBase, crossbowType);
    if(!baseCrossbow) return;

    Il2CppObject* baseGrabbable = GO_GetComponentInChildren(goBase, grabbableType);
    if(!baseGrabbable) return;

    Il2CppObject* currentAnchor = nullptr;
    s_field_get_value(baseCrossbow, f_attachAnchor, &currentAnchor);
    if(!currentAnchor) return;

    for(int i = 0; i < g_crossbowStackAmmount.load(); i++)
    {
        Il2CppObject* goNext = SpawnItem(CreateMonoString("item_crossbow"),
                                             GetCamPosition(),0,0,0);

        Il2CppObject* nextGrabbable = GO_GetComponentInChildren(goNext, grabbableType);
        if(!nextGrabbable) return;

        NetworkBehaviourId nextId = get_Id(nextGrabbable);

        TryGrabObject(currentAnchor, nextId, false, true, false);

        Il2CppObject* nextCrossbow = GO_GetComponentInChildren(goNext, crossbowType);
        if(!nextCrossbow) break;

        Il2CppObject* nextAnchor = nullptr;
        s_field_get_value(nextCrossbow, f_attachAnchor, &nextAnchor);
        if(!nextAnchor) break;

        currentAnchor = nextAnchor;
    }    
}
static void SpawnMobGrenades()
{
    Il2CppObject* teleGrenadeType = TypeOf(TeleGrenade);
    Il2CppObject* trampolineType = TypeOf(Trampoline);
    Il2CppObject* roboMonkeItemType = TypeOf(RoboMonkeItem);
    Il2CppObject* typeNetPlayer = TypeOf(NetPlayer);
    Il2CppObject* typeChoppableTreeManager = TypeOf(ChoppableTreeManager);
    Il2CppObject* typeHordeMobSpawner = TypeOf(HordeMobSpawner);
    Il2CppObject* hordeMobControllerType = TypeOf(HordeMobController);
    Il2CppObject* gameObjectType = TypeOf(GameObject);
    Il2CppObject* netObjectSpawnGroupType = TypeOf(NetObjectSpawnGroup);
    Il2CppObject* randomPrefabType    = TypeOf(RandomPrefab);
    Il2CppObject* backpackType    = TypeOf(BackpackItem);
    Il2CppObject* quiverType    = TypeOf(Quiver);
    Il2CppObject* pickupManagerType = TypeOf(PickupManager);
    Il2CppObject* grabbableType = TypeOf(GrabbableItem);
    Il2CppObject* grabbableObjectType = TypeOf(GrabbableObject);
    Il2CppObject* lakeJobPartTwoType = TypeOf(LakeJobPartTwo);
    Il2CppObject* momBossItemSpawnerType = TypeOf(MomBossItemSpawner);
    Il2CppObject* flareGunType = TypeOf(FlareGun);
    Il2CppObject* momBossGameMusicalChairType = TypeOf(MomBossGameMusicalChair);
    Il2CppObject* balloonType = TypeOf(Balloon);

    MethodInfo* m_TeleGrenade = s_get_method_from_name(TeleGrenade, "RPC_Use", 2);
    if (!m_TeleGrenade || !m_TeleGrenade->methodPointer) return;
    using t_TeleGrenade = void(*)(Il2CppObject*, int, bool);
    auto RPC_Use = (t_TeleGrenade)STRIP_FP(m_TeleGrenade->methodPointer);

    auto m_TryAddItem = s_get_method_from_name(BackpackItem, "TryAddItem", 1);
    auto TryAddItem = (bool(*)(Il2CppObject*, Il2CppObject*))STRIP_FP(m_TryAddItem->methodPointer);

    Il2CppObject* goQuiver = SpawnItem(CreateMonoString("item_backpack_large_base"), GetCamPosition(), 0, 0, 0);
    Il2CppObject* quiver = GO_GetComponentInChildren(goQuiver, backpackType);

    auto ks = GetAllMobIds();
    for (uint32_t k : ks) 
    { 
        Il2CppObject* goTele = SpawnItem(CreateMonoString("item_tele_grenade"), GetCamPosition(), -50, -23, 0);
        Il2CppObject* tele = GO_GetComponentInChildren(goTele, teleGrenadeType);
        Il2CppObject* grabbable = GO_GetComponentInChildren(goTele, grabbableType);

        RPC_Use(tele, k, true);
        TryAddItem(quiver, grabbable);
    }
}
struct ValueTuple_String_String
{
    Il2CppObject* Item1;
    Il2CppObject* Item2;
};

static void CallSaveUserLoadoutTemplatesSlot1Empty(Il2CppObject* apiInstance)
{
   
}







static Il2CppClass* PhotonNetwork = nullptr;

static bool heavyStickdone;
static bool valueStickdone;
static bool stackCrossdone;
static bool mobGrenadedone;
static bool actionAlldone;

static void CustomTick()
{ 
    if (g_cfgItemSpammer.load())
    {
       
    }

}

@interface ACFramePump (Tick)
- (void)onFrame:(CADisplayLink*)link;
@end
@implementation ACFramePump (Tick)
- (void)onFrame:(CADisplayLink*)link { CustomTick(); }
@end

static void StartFramePump()
{
    if (g_displayLink) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        g_framePump = [ACFramePump new];
        g_displayLink = [CADisplayLink displayLinkWithTarget:g_framePump selector:@selector(onFrame:)];
        g_displayLink.preferredFramesPerSecond = 60;
        [g_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        KITTY_LOGI("FramePump started with CADisplayLink  ");
    });
}
void initStuff(MemoryFileInfo framework)
{
    using t_get_method_from_name   = MethodInfo*(*)(Il2CppClass*, const char*, int);
    using t_string_length          = int32_t(*)(Il2CppString*);
    using t_string_chars           = Il2CppChar*(*)(Il2CppString*);
    using t_type_get_object        = Il2CppObject*(*)(const Il2CppType*);
    using t_string_new             = Il2CppString*(*)(const char*);
    using t_runtime_invoke         = Il2CppObject*(*)(const MethodInfo*, void*, void**, Il2CppException**);
    using t_class_get_field_from_name = FieldInfo*(*)(Il2CppClass*, const char*);
    using t_object_get_class       = Il2CppClass*(*)(Il2CppObject*);
    using t_field_get_value        = void(*)(Il2CppObject*, FieldInfo*, void*);
    using t_field_set_value        = void(*)(Il2CppObject*, FieldInfo*, void*);
    using t_field_static_get_value = void(*)(FieldInfo*, void*);
    using t_class_get_methods      = const MethodInfo*(*)(Il2CppClass*, void**);
    using t_class_get_namespace    = const char*(*)(Il2CppClass*);
    using t_class_get_name         = const char*(*)(Il2CppClass*);
    using t_type_get_name          = char*(*)(const Il2CppType*);
    using t_object_unbox           = void*(*)(Il2CppObject*);
    using t_value_box              = Il2CppObject*(*)(Il2CppClass*, void*);
    using t_get_class_from_name    = Il2CppClass*(*)(const Il2CppImage*, const char*, const char*);

    static t_get_method_from_name   s_get_method_from_name = nullptr;
    static t_string_length          string_length = nullptr;
    static t_string_chars           string_chars = nullptr;
    static t_type_get_object        s_type_get_object = nullptr;
    static t_string_new             s_string_new = nullptr;
    static t_runtime_invoke         s_runtime_invoke = nullptr;
    static t_class_get_field_from_name s_class_get_field_from_name = nullptr;
    static t_object_get_class       s_object_get_class = nullptr;
    static t_field_get_value        s_field_get_value = nullptr;
    static t_field_set_value        s_field_set_value = nullptr;
    static t_field_static_get_value s_field_static_get_value = nullptr;
    static t_class_get_methods      s_class_get_methods = nullptr;
    static t_class_get_namespace    s_class_get_namespace = nullptr;
    static t_class_get_name         s_class_get_name = nullptr;
    static t_type_get_name          s_type_get_name = nullptr;
    static t_object_unbox           s_object_unbox = nullptr;
    static t_value_box              s_value_box = nullptr;
    static t_get_class_from_name    s_get_class_from_name = nullptr;

    auto domain_get      = (Il2CppDomain*(*)())KittyScanner::findSymbol(framework, "_il2cpp_domain_get");
    auto get_assemblies  = (Il2CppAssembly**(*)(const Il2CppDomain*, size_t*))KittyScanner::findSymbol(framework, "_il2cpp_domain_get_assemblies");
    auto get_image       = (Il2CppImage*(*)(const Il2CppAssembly*))KittyScanner::findSymbol(framework, "_il2cpp_assembly_get_image");
    auto get_class_count = (size_t(*)(const Il2CppImage*))KittyScanner::findSymbol(framework, "_il2cpp_image_get_class_count");
    auto get_class       = (Il2CppClass*(*)(const Il2CppImage*, size_t))KittyScanner::findSymbol(framework, "_il2cpp_image_get_class");
    auto thread_attach   = (void*(*)(Il2CppDomain*))KittyScanner::findSymbol(framework, "_il2cpp_thread_attach");

    s_get_method_from_name      = (t_get_method_from_name)KittyScanner::findSymbol(framework, "_il2cpp_class_get_method_from_name");
    string_length               = (t_string_length)KittyScanner::findSymbol(framework, "_il2cpp_string_length");
    string_chars                = (t_string_chars)KittyScanner::findSymbol(framework, "_il2cpp_string_chars");
    s_type_get_object           = (t_type_get_object)KittyScanner::findSymbol(framework, "_il2cpp_type_get_object");
    s_string_new                = (t_string_new)KittyScanner::findSymbol(framework, "_il2cpp_string_new");
    s_runtime_invoke            = (t_runtime_invoke)KittyScanner::findSymbol(framework, "_il2cpp_runtime_invoke");
    s_class_get_field_from_name = (t_class_get_field_from_name)KittyScanner::findSymbol(framework, "_il2cpp_class_get_field_from_name");
    s_object_get_class          = (t_object_get_class)KittyScanner::findSymbol(framework, "_il2cpp_object_get_class");
    s_field_get_value           = (t_field_get_value)KittyScanner::findSymbol(framework, "_il2cpp_field_get_value");
    s_field_set_value           = (t_field_set_value)KittyScanner::findSymbol(framework, "_il2cpp_field_set_value");
    s_field_static_get_value    = (t_field_static_get_value)KittyScanner::findSymbol(framework, "_il2cpp_field_static_get_value");
    s_class_get_methods         = (t_class_get_methods)KittyScanner::findSymbol(framework, "_il2cpp_class_get_methods");
    s_class_get_namespace       = (t_class_get_namespace)KittyScanner::findSymbol(framework, "_il2cpp_class_get_namespace");
    s_class_get_name            = (t_class_get_name)KittyScanner::findSymbol(framework, "_il2cpp_class_get_name");
    s_type_get_name             = (t_type_get_name)KittyScanner::findSymbol(framework, "_il2cpp_type_get_name");
    s_object_unbox              = (t_object_unbox)KittyScanner::findSymbol(framework, "_il2cpp_object_unbox");
    s_value_box                 = (t_value_box)KittyScanner::findSymbol(framework, "_il2cpp_value_box");
    s_get_class_from_name       = (t_get_class_from_name)KittyScanner::findSymbol(framework, "_il2cpp_class_from_name");

    if (!domain_get || !get_assemblies || !get_image || !get_class_count || !get_class || !thread_attach ||
        !s_get_method_from_name || !string_length || !string_chars || !s_runtime_invoke)
    {
        NSLog(@"[Kitty] Missing one or more required IL2CPP exports");
        return;
    }

    auto domain = domain_get();
    if (!domain)
    {
        NSLog(@"[Kitty] il2cpp_domain_get returned null");
        return;
    }

    thread_attach(domain);

    size_t size = 0;
    auto assemblies = get_assemblies(domain, &size);
    if (!assemblies || size == 0)
    {
        NSLog(@"[Kitty] il2cpp_domain_get_assemblies returned no assemblies");
        return;
    }

    imageMap.clear();
    classMap.clear();

    int totalClasses = 0;

    for (size_t i = 0; i < size; ++i)
    {
        auto assembly = assemblies[i];
        if (!assembly) continue;

        auto image = get_image(assembly);
        if (!image) continue;

        std::string imageName = image->name ? image->name : "";
        imageMap[imageName] = image;

        size_t cc = get_class_count(image);
        for (size_t k = 0; k < cc; ++k)
        {
            Il2CppClass* klass = get_class(image, k);
            if (!klass) continue;

            const char* ns = klass->namespaze ? klass->namespaze : "";
            const char* name = klass->name ? klass->name : "";

            classMap[std::string(ns)][std::string(name)] = klass;
            totalClasses++;
        }
    }

    KITTY_LOGI("Initialized %d total namespaces with %d total classes", (int)classMap.size(), totalClasses);

    AuthenticationValues           = classMap["Photon.Realtime"]["AuthenticationValues"];
    PhotonNetwork           = classMap["Photon.Pun"]["PhotonNetwork"];

    auto nsPun = classMap.find("Photon.Pun");
    if (nsPun != classMap.end())
    {
        auto it = nsPun->second.find("PhotonNetwork");
        if (it != nsPun->second.end())
            PhotonNetwork = it->second;
    }

    auto nsRealtime = classMap.find("Photon.Realtime");
    if (nsRealtime != classMap.end())
    {
        auto it = nsRealtime->second.find("AuthenticationValues");
        if (it != nsRealtime->second.end())
            AuthenticationValues = it->second;
    }

    if (!PhotonNetwork || !AuthenticationValues)
    {
        NSLog(@"[Kitty] Missing Photon classes");
        return;
    }

    auto m_get_AuthValues = s_get_method_from_name(PhotonNetwork, "get_AuthValues", 0);
    if (!m_get_AuthValues)
    {
        NSLog(@"[Kitty] PhotonNetwork.get_AuthValues not found");
        return;
    }

    auto m_toString = s_get_method_from_name(AuthenticationValues, "ToString", 0);
    auto m_get_AuthGetParameters = s_get_method_from_name(AuthenticationValues, "get_AuthGetParameters", 0);
    auto m_get_AuthPostData = s_get_method_from_name(AuthenticationValues, "get_AuthPostData", 0);
    auto m_get_AuthType = s_get_method_from_name(AuthenticationValues, "get_AuthType", 0);
    auto m_get_Token = s_get_method_from_name(AuthenticationValues, "get_Token", 0);
    auto m_get_UserId = s_get_method_from_name(AuthenticationValues, "get_UserId", 0);

    Il2CppObject* authObj = nullptr;

    while(authObj == nullptr)
    {
        Il2CppException* ex = nullptr;
        authObj = s_runtime_invoke(m_get_AuthValues, nullptr, nullptr, &ex);

        if (ex)
        {
            NSLog(@"[Kitty] get_AuthValues threw exception while waiting");
            return;
        }

        if (authObj)
            break;

        NSLog(@"[Kitty] get_AuthValues returned null, retrying...");
        sleep(1);
    }


    Il2CppException* ex = nullptr;
    Il2CppObject* strObj = s_runtime_invoke(m_toString, authObj, nullptr, &ex);
    Il2CppObject* getParams = s_runtime_invoke(m_get_AuthGetParameters, authObj, nullptr, &ex);
    Il2CppObject* postData = s_runtime_invoke(m_get_AuthPostData, authObj, nullptr, &ex);
    Il2CppObject* token = s_runtime_invoke(m_get_Token, authObj, nullptr, &ex);
    Il2CppObject* userId = s_runtime_invoke(m_get_UserId, authObj, nullptr, &ex);

    Il2CppString* sObj = (Il2CppString*)strObj;
    Il2CppString* sP = (Il2CppString*)getParams;
    Il2CppString* sD = (Il2CppString*)postData;
    Il2CppString* sT = (Il2CppString*)token;
    Il2CppString* sU = (Il2CppString*)userId;

    std::string s = il2cpp_string_to_std(sObj, string_chars, string_length);
    KITTY_LOGI("[Kitty] AuthValues.ToString => %{public}s", s.c_str());

    std::string sAuthGetParameters = il2cpp_string_to_std(sP, string_chars, string_length);
    KITTY_LOGI("[Kitty] AuthValues AuthGetParameters => %{public}s", sAuthGetParameters.c_str());

    std::string spostData = il2cpp_string_to_std(sD, string_chars, string_length);
    KITTY_LOGI("[Kitty] AuthValues AuthPostData=> %{public}s", spostData.c_str());

    std::string stoken = il2cpp_string_to_std(sT, string_chars, string_length);
    KITTY_LOGI("[Kitty] AuthValues Token => %{public}s", stoken.c_str());

    std::string suserId = il2cpp_string_to_std(sU, string_chars, string_length);
    KITTY_LOGI("[Kitty] AuthValues UserId => %{public}s", suserId.c_str());

        auto m_get_CurrentRoom = s_get_method_from_name(PhotonNetwork, "get_CurrentRoom", 0);
        Il2CppObject* roomObj = nullptr;

        while(roomObj == nullptr)
        {
            Il2CppException* ex = nullptr;
            roomObj = s_runtime_invoke(m_get_CurrentRoom, nullptr, nullptr, &ex);

            if (ex)
            {
                NSLog(@"[Kitty] room threw exception while waiting");
                return;
            }

            if (roomObj)
                break;

            NSLog(@"[Kitty] room returned null, retrying...");
            sleep(1);
        }
       std::thread([] {
                sleep(10);
               auto m_SendDestroyOfAll = s_get_method_from_name(PhotonNetwork, "SendDestroyOfAll", 0);
               s_runtime_invoke(m_SendDestroyOfAll, nullptr, nullptr, &ex);
               NSLog(@"[Kitty] destroyed all...");
               
        }).detach();



    StartConfigPoll();
    StartFramePump();
}



__attribute__ ((constructor))
void lib_main() {
    static bool didOnce = false;
    if (didOnce) return;
    didOnce = true;

    std::thread([] {
        @autoreleasepool 
        {
            KITTY_LOGI("====================== LOADED =====================");
            KITTY_LOGI("App Executable: %{public}s", KittyMemory::getBaseInfo().name);
            MemoryFileInfo g_BaseInfo;
            do {
                sleep(3);
                g_BaseInfo = KittyMemory::getMemoryFileInfo("UnityFramework");
            } while (!g_BaseInfo.address);
            initStuff(g_BaseInfo);
        }
    }).detach();
}