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

static std::atomic<bool> g_cfgDestroyAll{false};
static std::atomic<bool> g_cfgDeleteAll{false};

static constexpr size_t kContainedItemCoreDataSize = 0x1C;
static constexpr size_t kQuiver_TempItemState_Offset = 0xB8;

static std::atomic<bool> g_pollStarted{false};
static const char*       kModCfgURL = "https://yeepsapi.onrender.com/api/mod";

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

    v = d[@"destroyAll"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgDestroyAll.store([(NSNumber*)v boolValue]);
    v = d[@"deleteAll"]; if ([v isKindOfClass:[NSNumber class]]) g_cfgDeleteAll.store([(NSNumber*)v boolValue]);
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
                _ScheduleNextFetch(0.15);
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

static Il2CppClass* PhotonNetwork = nullptr;
static Il2CppClass* PhotonView = nullptr;
static Il2CppClass* Player = nullptr;
static Il2CppClass* NetworkMessenger = nullptr;

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
static void DeleteAll()
{
    
    Il2CppException* ex = nullptr;

    FieldInfo* f_pv   = s_class_get_field_from_name(NetworkMessenger, "][[][]]][[]]][[][]][][][[][[[]][]][[[[][]]][]]]");
    if (!f_pv) {
        NSLog(@"[Kitty] one or more fields are missing");
        return;
    }
    Il2CppObject *spv   = nullptr;

    auto m_set_ControllerActorNr = s_get_method_from_name(PhotonView, "set_ControllerActorNr", 1);
    auto m_set_OwnerActorNr = s_get_method_from_name(PhotonView, "set_OwnerActorNr", 1);

    auto m_get_LocalPlayer = s_get_method_from_name(PhotonNetwork, "get_LocalPlayer", 0);
    Il2CppObject* local = s_runtime_invoke(m_get_LocalPlayer, nullptr, nullptr, &ex);

    auto m_get_ActorNumber = s_get_method_from_name(Player, "get_ActorNumber", 0);
    auto actor = s_runtime_invoke(m_get_ActorNumber, local, nullptr, &ex);

    static MethodInfo* m_FindObjectsOfType = nullptr;
    if (!m_FindObjectsOfType) 
    {
        m_FindObjectsOfType = s_get_method_from_name(GameObject, "FindObjectsOfType", 1);
        if (!m_FindObjectsOfType || !m_FindObjectsOfType->methodPointer) 
        {
            NSLog(@"[Kitty] : FindObjectsOfType(Type) not found");
            return;
        }
    }
    Il2CppObject* typeNetworkMessenger = TypeOf(NetworkMessenger);
    if (!typeNetworkMessenger) 
    {
        NSLog(@"[Kitty] : TypeOf() failed");
        return;
    }
    Il2CppException* ex3 = nullptr;
    void* argsFO[1] = { typeNetworkMessenger };
    Il2CppObject* arrObj = s_runtime_invoke(m_FindObjectsOfType, nullptr, argsFO, &ex3);
    if (ex || !arrObj) 
    {
        NSLog(@"[Kitty] : FindObjectsOfType failed ex=%p arr=%p", ex3, arrObj);
        return;
    }
    Il2CppArray* arr = (Il2CppArray*)arrObj;
    if (!arr || arr->max_length == 0) 
    {
        NSLog(@"[Kitty] : no instances");
        return;
    }
        
    Il2CppObject** elems = (Il2CppObject**)((char*)arr + sizeof(Il2CppArray));
    for (il2cpp_array_size_t i = 0; i < arr->max_length; ++i) 
    {
        Il2CppObject* nm = elems[i];
        Il2CppObject* pv = s_field_get_value(nm, f_pv,   &spv);

        void* argsFO3[1] = { actor };
        s_runtime_invoke(m_set_ControllerActorNr, pv, argsFO3, &ex);
        void* argsFO2[1] = { actor };
        s_runtime_invoke(m_set_OwnerActorNr, pv, argsFO2, &ex);
    }
}
static void DestroyAll()
{
    Il2CppException* ex = nullptr;
    auto m_SendDestroyOfAll = s_get_method_from_name(PhotonNetwork, "SendDestroyOfAll", 0);
    s_runtime_invoke(m_SendDestroyOfAll, nullptr, nullptr, &ex);
    NSLog(@"[Kitty] destroyed all...");    
}



static void CustomTick()
{ 
    if (g_cfgDestroyAll.load())
    {
        NSLog(@"[Kitty] destroyed all called");
        DestroyAll();
    }
    if (g_cfgDeleteAll.load())
    {
       DeleteAll();
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

    GameObject           = classMap["UnityEngine"]["GameObject"];
    Resources            = classMap["UnityEngine"]["Resources"];
    Component            = classMap["UnityEngine"]["Component"];
    Transform            = classMap["UnityEngine"]["Transform"];
    AuthenticationValues           = classMap["Photon.Realtime"]["AuthenticationValues"];
    PhotonNetwork           = classMap["Photon.Pun"]["PhotonNetwork"];
    PhotonView           = classMap["Photon.Pun"]["PhotonView"];
    Player           = classMap["Photon.Realtime"]["Player"];
    NetworkMessenger           = classMap[""]["NetworkMessenger"];


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