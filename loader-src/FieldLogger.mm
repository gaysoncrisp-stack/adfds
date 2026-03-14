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
static Il2CppClass* (*s_get_class_from_name)(
    const Il2CppImage*,
    const char*,
    const char*
) = nullptr;
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

static Il2CppDomain* g_domain = nullptr;
static void* (*g_thread_attach)(Il2CppDomain*) = nullptr;
static thread_local bool g_threadAttached = false;



static Il2CppClass* PhotonNetwork = nullptr;
static Il2CppClass* PhotonView = nullptr;
static Il2CppClass* Player = nullptr;
static Il2CppClass* NetworkMessenger = nullptr;
static Il2CppClass* PhotonHandler = nullptr;


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
static void DeleteAll()
{
    Il2CppException* ex = nullptr;

    FieldInfo* f_pv   = s_class_get_field_from_name(NetworkMessenger, "][[][]]][[]]][[][]][][][[][[[]][]][[[[][]]][]]]");
    if (!f_pv) {
        NSLog(@"[Kitty] one or more fields are missing");
        return;
    }
    Il2CppObject *pv = nullptr;

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
        s_field_get_value(nm, f_pv, &pv);

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

typedef void(*orig_Update_t)(Il2CppObject*);
orig_Update_t orig_Update = nullptr;
void my_Update(Il2CppObject* self)
{
    NSLog(@"[Kitty] Update called");

    orig_Update(self);
}
static NSString* NSStr(Il2CppString* s)
{
    if (!s) return @"<null>";
    return [NSString stringWithCharacters:(const unichar*)s->chars length:s->length];
}
static NSString* DumpVec3(const Vector3& v)
{
    return [NSString stringWithFormat:@"(%.4f, %.4f, %.4f)", v.x, v.y, v.z];
}
static NSString* DumpQuat(const Quaternion& q)
{
    return [NSString stringWithFormat:@"(%.4f, %.4f, %.4f, %.4f)", q.x, q.y, q.z, q.w];
}
static NSString* DumpStringArray(Il2CppArray* arr)
{
    if (!arr) return @"<null>";

    NSMutableString* out = [NSMutableString stringWithString:@"["];

    auto data = (Il2CppString**)((uint8_t*)arr + sizeof(Il2CppArray));

    for (uintptr_t i = 0; i < arr->max_length; i++)
    {
        NSString* s = NSStr(data[i]);
        [out appendString:s ? s : @"<null>"];

        if (i + 1 < arr->max_length)
            [out appendString:@", "];
    }

    [out appendString:@"]"];
    return out;
}
static const char* SafeUtf8(NSString* s)
{
    return s ? [s UTF8String] : "<null>";
}
static const char* SafeIl2CppStr(Il2CppString* s)
{
    return SafeUtf8(NSStr(s));
}
static std::string Vec3Str(const Vector3& v)
{
    char buf[128];
    snprintf(buf, sizeof(buf), "(%.4f, %.4f, %.4f)", v.x, v.y, v.z);
    return std::string(buf);
}
static std::string QuatStr(const Quaternion& q)
{
    char buf[160];
    snprintf(buf, sizeof(buf), "(%.4f, %.4f, %.4f, %.4f)", q.x, q.y, q.z, q.w);
    return std::string(buf);
}
static std::string DumpStringArrayCpp(Il2CppArray* arr)
{
    if (!arr) return "<null>";

    std::string out = "[";
    auto data = (Il2CppString**)((uint8_t*)arr + sizeof(Il2CppArray));

    for (uintptr_t i = 0; i < arr->max_length; i++)
    {
        out += SafeIl2CppStr(data[i]);
        if (i + 1 < arr->max_length)
            out += ", ";
    }

    out += "]";
    return out;
}
typedef void(*orig_RpcCreateItem_t)(
    Il2CppObject* self,
    Il2CppString* a1,
    Il2CppString* a2,
    uintptr_t a3,
    Il2CppString* a4,
    Vector3 a5,
    Quaternion a6,
    Vector3 a7,
    Vector3 a8,
    Il2CppArray* a9,
    uint8_t a10,
    uint8_t a11,
    uint64_t info0,
    uint64_t info1,
    uint64_t info2,
    uint64_t info3
);

orig_RpcCreateItem_t orig_RpcCreateItem = nullptr;

void my_RpcCreateItem(
    Il2CppObject* self,
    Il2CppString* a1,
    Il2CppString* a2,
    uintptr_t a3,
    Il2CppString* a4,
    Vector3 a5,
    Quaternion a6,
    Vector3 a7,
    Vector3 a8,
    Il2CppArray* a9,
    uint8_t a10,
    uint8_t a11,
    uint64_t info0,
    uint64_t info1,
    uint64_t info2,
    uint64_t info3
)
{
    std::string v5 = Vec3Str(a5);
    std::string q6 = QuatStr(a6);
    std::string v7 = Vec3Str(a7);
    std::string v8 = Vec3Str(a8);
    std::string arr9 = DumpStringArrayCpp(a9);

    KITTY_LOGI("[Kitty] RpcCreateItem called");
    KITTY_LOGI("[Kitty] self => %{public}p", self);
    KITTY_LOGI("[Kitty] arg1 => %{public}s", SafeIl2CppStr(a1));
    KITTY_LOGI("[Kitty] arg2 => %{public}s", SafeIl2CppStr(a2));
    KITTY_LOGI("[Kitty] arg3 => 0x%{public}llX", (unsigned long long)a3);
    KITTY_LOGI("[Kitty] arg4 => %{public}s", SafeIl2CppStr(a4));
    KITTY_LOGI("[Kitty] arg5 => %{public}s", v5.c_str());
    KITTY_LOGI("[Kitty] arg6 => %{public}s", q6.c_str());
    KITTY_LOGI("[Kitty] arg7 => %{public}s", v7.c_str());
    KITTY_LOGI("[Kitty] arg8 => %{public}s", v8.c_str());
    KITTY_LOGI("[Kitty] arg9 => %{public}s", arr9.c_str());
    KITTY_LOGI("[Kitty] arg10 => %{public}u", (unsigned)a10);
    KITTY_LOGI("[Kitty] arg11 => %{public}u", (unsigned)a11);
    KITTY_LOGI(
        "[Kitty] PhotonMessageInfo raw => %{public}016llX %{public}016llX %{public}016llX %{public}016llX",
        (unsigned long long)info0,
        (unsigned long long)info1,
        (unsigned long long)info2,
        (unsigned long long)info3
    );

    orig_RpcCreateItem(
        self,
        a1,
        a2,
        a3,
        a4,
        a5,
        a6,
        a7,
        a8,
        a9,
        a10,
        a11,
        info0,
        info1,
        info2,
        info3
    );
}
static void InitHooks()
{
    if(!NetworkMessenger)
    {
         NSLog(@"[Kitty] NetworkMessenger not found");
        return;
    }
    auto m_RpcCreateItem = s_get_method_from_name(NetworkMessenger, "RpcCreateItem", 13);
    if (!m_RpcCreateItem)
    {
        NSLog(@"[Kitty] RpcCreateItem method not found");
        return;
    }

    orig_RpcCreateItem = (orig_RpcCreateItem_t)m_RpcCreateItem->methodPointer;
    m_RpcCreateItem->methodPointer = (Il2CppMethodPointer)my_RpcCreateItem;

    NSLog(@"[Kitty] Hooked RpcCreateItem at %p", m_RpcCreateItem->methodPointer);
}




static Il2CppClass* UnityObject = nullptr;
static MethodInfo* m_Object_FindObjectsOfType = nullptr;

static Il2CppArray* FindObjectsOfType(Il2CppClass* klass)
{
    if (!klass)
    {
        KITTY_LOGI("[Kitty] FindObjectsOfType: klass null");
        return nullptr;
    }

    if (!UnityObject)
    {
        KITTY_LOGI("[Kitty] FindObjectsOfType: UnityObject class null");
        return nullptr;
    }

    if (!m_Object_FindObjectsOfType)
    {
        m_Object_FindObjectsOfType = s_get_method_from_name(UnityObject, "FindObjectsOfType", 1);
        if (!m_Object_FindObjectsOfType || !m_Object_FindObjectsOfType->methodPointer)
        {
            KITTY_LOGI("[Kitty] FindObjectsOfType(Type) not found");
            return nullptr;
        }
    }

    Il2CppObject* typeObj = TypeOf(klass);
    if (!typeObj)
    {
        KITTY_LOGI("[Kitty] FindObjectsOfType: TypeOf failed");
        return nullptr;
    }

    void* args[1] = { typeObj };
    Il2CppException* ex = nullptr;
    Il2CppObject* ret = s_runtime_invoke(m_Object_FindObjectsOfType, nullptr, args, &ex);

    if (ex || !ret)
    {
        KITTY_LOGI("[Kitty] FindObjectsOfType invoke failed ex=%{public}p ret=%{public}p", ex, ret);
        return nullptr;
    }

    return (Il2CppArray*)ret;
}
static Il2CppArray* (*s_array_new)(Il2CppClass*, il2cpp_array_size_t) = nullptr;
 
static void LogIl2CppExceptionDetailed(const char* where, Il2CppException* ex)
{
    if (!ex)
    {
        KITTY_LOGI("[Kitty] %s => no exception", where);
        return;
    }

    std::string exType;
    std::string exMsg;
    std::string exToStr;

    Il2CppClass* exKlass = s_object_get_class ? s_object_get_class((Il2CppObject*)ex) : nullptr;
    if (exKlass)
    {
        const char* ns = s_class_get_namespace ? s_class_get_namespace(exKlass) : "";
        const char* name = s_class_get_name ? s_class_get_name(exKlass) : "";
        exType = std::string(ns ? ns : "") + "." + std::string(name ? name : "");
    }

    if (s_get_method_from_name && s_runtime_invoke)
    {
        MethodInfo* m_getMessage = exKlass ? s_get_method_from_name(exKlass, "get_Message", 0) : nullptr;
        if (m_getMessage && m_getMessage->methodPointer)
        {
            Il2CppException* innerEx = nullptr;
            Il2CppObject* msgObj = s_runtime_invoke(m_getMessage, ex, nullptr, &innerEx);
            if (!innerEx && msgObj)
                exMsg = ObjToString(msgObj);
        }

        exToStr = ObjToString((Il2CppObject*)ex);
    }

    KITTY_LOGI("[Kitty] %s exception type => %{public}s", where, exType.empty() ? "<unknown>" : exType.c_str());
    KITTY_LOGI("[Kitty] %s exception message => %{public}s", where, exMsg.empty() ? "<none>" : exMsg.c_str());
    KITTY_LOGI("[Kitty] %s exception tostring => %{public}s", where, exToStr.empty() ? "<none>" : exToStr.c_str());
}
static std::string GetTypeNameSafe(const Il2CppType* t)
{
    if (!t || !s_type_get_name) return "<null>";
    const char* n = s_type_get_name(t);
    return n ? n : "<null>";
}
static const Il2CppType* GetMethodParamType(const MethodInfo* m, uint8_t index)
{
    if (!m) return nullptr;
    if (index >= m->parameters_count) return nullptr;
    if (!m->parameters) return nullptr;
    return m->parameters[index];
}
static void DumpMethodSignature(const char* prefix, const MethodInfo* m)
{
    if (!m)
    {
        KITTY_LOGI("[Kitty] %s <null method>", prefix);
        return;
    }

    std::string retType = GetTypeNameSafe(m->return_type);
    const char* methodName = m->name ? m->name : "<null>";

    std::string sig = retType + " " + methodName + "(";
    for (uint8_t i = 0; i < m->parameters_count; i++)
    {
        const Il2CppType* pType = GetMethodParamType(m, i);
        sig += GetTypeNameSafe(pType);

        if (i + 1 < m->parameters_count)
            sig += ", ";
    }
    sig += ")";

    KITTY_LOGI("[Kitty] %s %{public}s", prefix, sig.c_str());
}
static MethodInfo* FindPhotonViewRpcTargetOverload()
{
    if (!PhotonView || !s_class_get_methods)
        return nullptr;

    void* iter = nullptr;
    const MethodInfo* m = nullptr;
    MethodInfo* found = nullptr;

    while ((m = (const MethodInfo*)s_class_get_methods(PhotonView, &iter)))
    {
        if (!m->name) continue;
        if (strcmp(m->name, "RPC") != 0) continue;
        if (m->parameters_count != 3) continue;

        std::string p0 = GetTypeNameSafe(GetMethodParamType(m, 0));
        std::string p1 = GetTypeNameSafe(GetMethodParamType(m, 1));
        std::string p2 = GetTypeNameSafe(GetMethodParamType(m, 2));

        KITTY_LOGI("[Kitty] PhotonView RPC candidate => %{public}s | %{public}s | %{public}s",
                   p0.c_str(), p1.c_str(), p2.c_str());
        DumpMethodSignature("PhotonView.RPC overload:", m);

        bool ok0 = (p0 == "System.String");
        bool ok1 = (p1 == "Photon.Pun.RpcTarget");
        bool ok2 = (p2 == "System.Object[]");

        if (ok0 && ok1 && ok2)
            found = (MethodInfo*)m;
    }

    return found;
}
static MethodInfo* FindNetworkMessengerRpcCreateItem()
{
    if (!NetworkMessenger || !s_class_get_methods)
        return nullptr;

    void* iter = nullptr;
    const MethodInfo* m = nullptr;
    MethodInfo* found = nullptr;

    while ((m = (const MethodInfo*)s_class_get_methods(NetworkMessenger, &iter)))
    {
        if (!m->name) continue;
        if (strcmp(m->name, "RpcCreateItem") != 0) continue;

        DumpMethodSignature("NetworkMessenger.RpcCreateItem candidate:", m);
        found = (MethodInfo*)m;
    }

    return found;
}
static Il2CppObject* BoxValue(Il2CppClass* klass, void* valuePtr)
{
    if (!klass || !s_value_box) return nullptr;
    return s_value_box(klass, valuePtr);
}
static Il2CppArray* NewObjectArray(il2cpp_array_size_t len)
{
    Il2CppClass* objectClass = classMap["System"]["Object"];
    if (!objectClass || !s_array_new) return nullptr;
    return s_array_new(objectClass, len);
}
static Il2CppArray* NewStringArray(il2cpp_array_size_t len)
{
    Il2CppClass* stringClass = classMap["System"]["String"];
    if (!stringClass || !s_array_new) return nullptr;
    return s_array_new(stringClass, len);
}
static void DumpParamsArray(Il2CppArray* arr)
{
    if (!arr)
    {
        KITTY_LOGI("[Kitty] paramsArray => null");
        return;
    }

    KITTY_LOGI("[Kitty] paramsArray length => %{public}d", (int)arr->max_length);

    auto elems = (Il2CppObject**)((uint8_t*)arr + sizeof(Il2CppArray));
    for (int i = 0; i < (int)arr->max_length; i++)
    {
        Il2CppObject* obj = elems[i];
        if (!obj)
        {
            KITTY_LOGI("[Kitty] params[%{public}d] => null", i);
            continue;
        }

        Il2CppClass* k = s_object_get_class ? s_object_get_class(obj) : nullptr;
        const char* ns = k && s_class_get_namespace ? s_class_get_namespace(k) : "";
        const char* name = k && s_class_get_name ? s_class_get_name(k) : "";
        std::string toStr = ObjToString(obj);

        KITTY_LOGI("[Kitty] params[%{public}d] type => %{public}s.%{public}s",
                   i, ns ? ns : "", name ? name : "");
        KITTY_LOGI("[Kitty] params[%{public}d] tostring => %{public}s",
                   i, toStr.empty() ? "<none>" : toStr.c_str());
    }
}
static void FindAllNetworkMessengers()
{
    Il2CppArray* arr = FindObjectsOfType(NetworkMessenger);
    if (!arr)
    {
        KITTY_LOGI("[Kitty] no NetworkMessenger array returned");
        return;
    }

    KITTY_LOGI("[Kitty] found %{public}d NetworkMessengers", (int)arr->max_length);

    FieldInfo* f_pv = s_class_get_field_from_name(NetworkMessenger, "[[][[[[][][[[[[][[[[]][]]]]][[[[[[]]][][][][[]]");
    if (!f_pv)
    {
        KITTY_LOGI("[Kitty] PhotonView field not found");
        return;
    }

    MethodInfo* m_RPC = FindPhotonViewRpcTargetOverload();
    if (!m_RPC || !m_RPC->methodPointer)
    {
        KITTY_LOGI("[Kitty] exact PhotonView.RPC(string, RpcTarget, object[]) overload not found");
        return;
    }

    KITTY_LOGI("[Kitty] selected PhotonView.RPC overload:");
    DumpMethodSignature("SELECTED", m_RPC);

    MethodInfo* m_RpcCreateItem = FindNetworkMessengerRpcCreateItem();
    if (!m_RpcCreateItem)
    {
        KITTY_LOGI("[Kitty] RpcCreateItem method not found on NetworkMessenger");
    }

    Il2CppClass* vector3Class = classMap["UnityEngine"]["Vector3"];
    Il2CppClass* quaternionClass = classMap["UnityEngine"]["Quaternion"];
    Il2CppClass* byteClass = classMap["System"]["Byte"];
    Il2CppClass* intPtrClass = classMap["System"]["IntPtr"];

    auto data = (Il2CppObject**)((uint8_t*)arr + sizeof(Il2CppArray));
    for (int i = 0; i < (int)arr->max_length; i++)
    {
        Il2CppObject* nm = data[i];
        if (!nm)
        {
            KITTY_LOGI("[Kitty] NetworkMessenger[%{public}d] is null", i);
            continue;
        }

        KITTY_LOGI("[Kitty] NetworkMessenger[%{public}d] => %{public}p", i, nm);

        Il2CppObject* pv = nullptr;
        s_field_get_value(nm, f_pv, &pv);

        if (!pv)
        {
            KITTY_LOGI("[Kitty] PhotonView is null for NetworkMessenger[%{public}d]", i);
            continue;
        }

        KITTY_LOGI("[Kitty] PhotonView => %{public}p", pv);

        Il2CppString* p0 = CreateMonoString("RpcCreateItem");
        int rpcTarget = 0;

        Il2CppString* arg1 = CreateMonoString("{a8.");
        Il2CppString* arg2 = CreateMonoString("throwingTeleporter");

        uintptr_t arg3Raw = 0;
        Il2CppObject* arg3 = BoxValue(intPtrClass, &arg3Raw);

        Il2CppString* arg4 = nullptr;

        Vector3 v5 = {0.8601f, 8.3237f, 2.2245f};
        Quaternion q6 = {0.0000f, 0.0000f, 0.0000f, 1.0000f};
        Vector3 v7 = {0.0000f, 0.0000f, 0.0000f};
        Vector3 v8 = {0.0000f, 0.0000f, 0.0000f};

        Il2CppObject* arg5 = BoxValue(vector3Class, &v5);
        Il2CppObject* arg6 = BoxValue(quaternionClass, &q6);
        Il2CppObject* arg7 = BoxValue(vector3Class, &v7);
        Il2CppObject* arg8 = BoxValue(vector3Class, &v8);

        Il2CppArray* arg9 = NewStringArray(0);

        uint8_t b10 = 1;
        uint8_t b11 = 1;
        Il2CppObject* arg10 = BoxValue(byteClass, &b10);
        Il2CppObject* arg11 = BoxValue(byteClass, &b11);

        Il2CppArray* paramsArray = NewObjectArray(11);
        if (!paramsArray)
        {
            KITTY_LOGI("[Kitty] Failed to allocate params object[]");
            continue;
        }

        auto elements = (Il2CppObject**)((uint8_t*)paramsArray + sizeof(Il2CppArray));
        elements[0] = (Il2CppObject*)arg1;
        elements[1] = (Il2CppObject*)arg2;
        elements[2] = arg3;
        elements[3] = (Il2CppObject*)arg4;
        elements[4] = arg5;
        elements[5] = arg6;
        elements[6] = arg7;
        elements[7] = arg8;
        elements[8] = (Il2CppObject*)arg9;
        elements[9] = arg10;
        elements[10] = arg11;

        KITTY_LOGI("[Kitty] methodName => RpcCreateItem");
        KITTY_LOGI("[Kitty] rpcTarget => %{public}d", rpcTarget);
        DumpParamsArray(paramsArray);

        Il2CppException* ex = nullptr;
        void* rpcArgs[3] = { p0, &rpcTarget, paramsArray };

        KITTY_LOGI("[Kitty] Calling PhotonView.RPC on NetworkMessenger[%{public}d]", i);
        s_runtime_invoke(m_RPC, pv, rpcArgs, &ex);

        if (ex)
        {
            LogIl2CppExceptionDetailed("PhotonView.RPC", ex);
            KITTY_LOGI("[Kitty] RPC call threw exception on NetworkMessenger[%{public}d]", i);
        }
        else
        {
            KITTY_LOGI("[Kitty] RPC called successfully on NetworkMessenger[%{public}d]", i);
        }
    }
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
        FindAllNetworkMessengers();
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
    using t_object_unbox           = void*(*)(Il2CppObject*);
    using t_value_box              = Il2CppObject*(*)(Il2CppClass*, void*);


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
    s_get_class_from_name = (decltype(s_get_class_from_name))KittyScanner::findSymbol(framework, "_il2cpp_class_from_name");
    s_array_new = (Il2CppArray*(*)(Il2CppClass*, il2cpp_array_size_t))KittyScanner::findSymbol(framework, "_il2cpp_array_new");

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
    g_domain = domain;
    g_thread_attach = (void*(*)(Il2CppDomain*))KittyScanner::findSymbol(framework, "_il2cpp_thread_attach");
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

    UnityObject = classMap["UnityEngine"]["Object"];
    GameObject  = classMap["UnityEngine"]["GameObject"];
    Resources   = classMap["UnityEngine"]["Resources"];
    Component   = classMap["UnityEngine"]["Component"];
    Transform   = classMap["UnityEngine"]["Transform"];
    AuthenticationValues           = classMap["Photon.Realtime"]["AuthenticationValues"];
    PhotonNetwork           = classMap["Photon.Pun"]["PhotonNetwork"];
    PhotonView           = classMap["Photon.Pun"]["PhotonView"];
    Player           = classMap["Photon.Realtime"]["Player"];
    NetworkMessenger           = classMap[""]["NetworkMessenger"];
    PhotonHandler           = classMap["Photon.Pun"]["PhotonHandler"];

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

    InitHooks();


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