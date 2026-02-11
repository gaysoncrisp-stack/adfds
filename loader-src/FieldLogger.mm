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

static std::mutex        g_cfgMu;
static std::mutex        g_cfgMd;
static std::mutex        g_cfgMx;

static std::mutex        g_cfgMp;
static std::mutex        g_cfgMf;

static constexpr size_t kContainedItemCoreDataSize = 0x1C;
static constexpr size_t kQuiver_TempItemState_Offset = 0xB8;

static std::atomic<bool> g_pollStarted{false};
Il2CppObject* runner = nullptr;
Il2CppObject* nmInstance = nullptr;

static Il2CppObject* SpawnItem(Il2CppString* item, Vector3 pos, int8_t scale, int8_t saturation, uint8_t hue, bool jelly = false)
{
        if (!g_SpawnItem) return nullptr;
        //ez way of getting methods 
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

static void CustomTick()
{       
    //update basically just run code here itll run every frame
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
    auto domain_get     = (Il2CppDomain*(*)())KittyScanner::findSymbol(framework, "_il2cpp_domain_get");
    auto get_assemblies = (Il2CppAssembly**(*)(const Il2CppDomain*, size_t*))KittyScanner::findSymbol(framework, "_il2cpp_domain_get_assemblies");
    auto get_image      = (Il2CppImage*(*)(const Il2CppAssembly*))KittyScanner::findSymbol(framework, "_il2cpp_assembly_get_image");
    auto get_class_count= (size_t(*)(const Il2CppImage*))KittyScanner::findSymbol(framework, "_il2cpp_image_get_class_count");
    auto get_class      = (Il2CppClass*(*)(const Il2CppImage*, size_t))KittyScanner::findSymbol(framework, "_il2cpp_image_get_class");

    s_get_method_from_name = (MethodInfo*(*)(Il2CppClass*, const char*, int))KittyScanner::findSymbol(framework, "_il2cpp_class_get_method_from_name");
    string_length     = (int32_t(*)(Il2CppString*))KittyScanner::findSymbol(framework, "_il2cpp_string_length");
    string_chars      = (Il2CppChar*(*)(Il2CppString*))KittyScanner::findSymbol(framework, "_il2cpp_string_chars");
    s_type_get_object      = (Il2CppObject*(*)(const Il2CppType*))KittyScanner::findSymbol(framework, "_il2cpp_type_get_object");
    s_string_new           = (Il2CppString*(*)(const char*))KittyScanner::findSymbol(framework, "_il2cpp_string_new");
    auto thread_attach     = (void*(*)(Il2CppDomain*))KittyScanner::findSymbol(framework, "_il2cpp_thread_attach");
    s_runtime_invoke       = (Il2CppObject*(*)(const MethodInfo*, void*, void**, Il2CppException**))KittyScanner::findSymbol(framework, "_il2cpp_runtime_invoke");

    s_class_get_field_from_name = (FieldInfo*(*)(Il2CppClass*, const char*))KittyScanner::findSymbol(framework, "_il2cpp_class_get_field_from_name");
    s_object_get_class          = (Il2CppClass*(*)(Il2CppObject*))KittyScanner::findSymbol(framework, "_il2cpp_object_get_class");
    s_field_get_value           = (void(*)(Il2CppObject*, FieldInfo*, void*))KittyScanner::findSymbol(framework, "_il2cpp_field_get_value");
    s_field_set_value           = (void(*)(Il2CppObject*, FieldInfo*, void*))KittyScanner::findSymbol(framework, "_il2cpp_field_set_value");
    s_field_static_get_value = (void(*)(FieldInfo*, void*))KittyScanner::findSymbol(framework, "_il2cpp_field_static_get_value");
    s_class_get_methods   = (t_class_get_methods)  KittyScanner::findSymbol(framework, "_il2cpp_class_get_methods");
    s_class_get_namespace = (t_class_get_namespace)KittyScanner::findSymbol(framework, "_il2cpp_class_get_namespace");
    s_class_get_name      = (t_class_get_name)     KittyScanner::findSymbol(framework, "_il2cpp_class_get_name");
    s_type_get_name       = (t_type_get_name)      KittyScanner::findSymbol(framework, "_il2cpp_type_get_name");


    if (!s_object_unbox) s_object_unbox = (void*(*)(Il2CppObject*))KittyScanner::findSymbol(framework, "_il2cpp_object_unbox");
    if (!s_value_box)          s_value_box          = (Il2CppObject*(*)(Il2CppClass*,void*))KittyScanner::findSymbol(framework, "_il2cpp_value_box");
    if (!s_get_class_from_name) s_get_class_from_name = (Il2CppClass*(*)(const char*,const char*))KittyScanner::findSymbol(framework, "_il2cpp_class_from_name");
        
    auto domain = domain_get();
    if (thread_attach && domain) thread_attach(domain);

    size_t size = 0;
    auto assemblies = get_assemblies(domain, &size);

    int okRealClasses = 0;
    for (int i = 0; i < (int)size; ++i) 
    {
        auto assembly = assemblies[i];
        auto image = get_image(assembly);
        if (!image) continue;
        imageMap[std::string(image->name)] = image;
        size_t cc = get_class_count(image);
        for (size_t k = 0; k < cc; ++k) {
            Il2CppClass* klass = get_class(image, k);
            if (!klass) continue;
            classMap[std::string(klass->namespaze)][std::string(klass->name)] = klass;
            okRealClasses++;
        }
    }
    KITTY_LOGI("Initialized %d total namespaces with %d total classes  ", okRealClasses, (int)classMap.size());

    //class map identiy classes

    GameObject           = classMap["UnityEngine"]["GameObject"];
    Resources            = classMap["UnityEngine"]["Resources"];
    Component            = classMap["UnityEngine"]["Component"];
    Transform            = classMap["UnityEngine"]["Transform"];
    GrabbableItem        = classMap["AnimalCompany"]["GrabbableItem"];
    GrabbableObject      = classMap["AnimalCompany"]["GrabbableObject"];
    NetSpectator         = classMap["AnimalCompany"]["NetSpectator"];
    NetPlayer            = classMap["AnimalCompany"]["NetPlayer"];
    PrefabGenerator      = classMap["AnimalCompany"]["PrefabGenerator"];
    NetworkManager       = classMap["AnimalCompany"]["NetworkManager"];
    BackpackItem         = classMap["AnimalCompany"]["BackpackItem"];
    GrabbableItemState   = classMap["AnimalCompany"]["GrabbableItemState"];
    JSONNode             = classMap["SimpleJSON"]["JSONNode"];

    NetworkRunner        = classMap["Fusion"]["NetworkRunner"];
    NetworkObject        = classMap["Fusion"]["NetworkObject"];
    NetworkPrefabTable        = classMap["Fusion"]["NetworkPrefabTable"];
    NetworkProjectConfig        = classMap["Fusion"]["NetworkProjectConfig"];
    NetworkObjectPrefabData        = classMap["Fusion"]["NetworkObjectPrefabData"];

    AuthenticationValues = classMap["Fusion.Photon.Realtime"]["AuthenticationValues"];;
    Session        = classMap["Nakama"]["Session"];
    NutDropManager        = classMap["AnimalCompany"]["NutDropManager"];
    NetSessionRPCs        = classMap["AnimalCompany"]["NetSessionRPCs"];
    NetworkSessionManager        = classMap["AnimalCompany"]["NetworkSessionManager"];
    App                  = classMap["AnimalCompany"]["App"];
    AppState             = classMap["AnimalCompany"]["AppState"];
    StatePrimitiveGeneric             = classMap["SpatialSys.ObservableState"]["StatePrimitive`1"];
    GameplayItemEquippingConfig             = classMap["AnimalCompany"]["GameplayItemEquippingConfig"];
    Quiver         = classMap["AnimalCompany"]["Quiver"];
    HeartGun         = classMap["AnimalCompany"]["HeartGun"];
    AttachedItemAnchor         = classMap["AnimalCompany"]["AttachedItemAnchor"];
    ChoppableTreeManager          = classMap["AnimalCompany"]["ChoppableTreeManager"];
    RoboMonkeItem          = classMap["AnimalCompany"]["RoboMonkeItem"];
    Trampoline          = classMap["AnimalCompany"]["Trampoline"];
    TeleGrenade          = classMap["AnimalCompany"]["TeleGrenade"];
    MobController          = classMap["AnimalCompany"]["MobController"];
    LakeJobPartTwo           = classMap["AnimalCompany"]["LakeJobPartTwo"];
    HordeMobSpawner           = classMap["AnimalCompany"]["HordeMobSpawner"];
    MomBossItemSpawner           = classMap["AnimalCompany"]["MomBossItemSpawner"];
    PickupManager           = classMap["AnimalCompany"]["PickupManager"];
    FlareGun           = classMap["AnimalCompany"]["FlareGun"];
    PrefabPool           = classMap["SpatialSys.PrefabPooling"]["PrefabPool"];
    AppPrefabPool           = classMap["AnimalCompany"]["AppPrefabPool"];
    NetObjectSpawnGroup           = classMap["AnimalCompany"]["NetObjectSpawnGroup"];
    RandomPrefab           = classMap["AnimalCompany"]["RandomPrefab"];
    HordeMobController           = classMap["AnimalCompany"]["HordeMobController"];
    MomBossGameMusicalChair            = classMap["AnimalCompany"]["MomBossGameMusicalChair"];
    Balloon            = classMap["AnimalCompany"]["Balloon"];
    GrenadeLauncher            = classMap["AnimalCompany"]["GrenadeLauncher"];
    HttpRequestAdapter            = classMap["AnimalCompany.API"]["HttpRequestAdapter"];
    AnimalCompanyAPI            = classMap["AnimalCompany.API"]["AnimalCompanyAPI"];
    CutieController            = classMap["AnimalCompany"]["CutieController"];
    NetworkBehaviour           = classMap["Fusion"]["NetworkBehaviour"];
    AppStartup           = classMap["AnimalCompany"]["AppStartup"];
    AuthCommands           = classMap["AnimalCompany"]["AuthCommands"];
    UserStashAndLoadoutSaveMediator           = classMap["AnimalCompany"]["UserStashAndLoadoutSaveMediator"];
    
    InitHooks();

    Il2CppObject* appStartupType = TypeOf(AppStartup);

    if (GameObject && s_get_method_from_name) 
    {
        if (auto m = s_get_method_from_name(GameObject, "SetActive", 1))
            if (m->methodPointer) GO_SetActive = (t_GO_SetActive)STRIP_FP(m->methodPointer);

        if (auto m = s_get_method_from_name(GameObject, "GetComponent", 1))
            if (m->methodPointer) GO_GetComponent = (t_GO_GetComponent)STRIP_FP(m->methodPointer);

        if (auto m = s_get_method_from_name(GameObject, "GetComponentInChildren", 1))
            if (m->methodPointer) GO_GetComponentInChildren = (t_GO_GetComponentInChildren)STRIP_FP(m->methodPointer);

        if (auto m = s_get_method_from_name(GameObject, "AddComponent", 1))
            if (m->methodPointer) GO_AddComponent = (t_GO_AddComponent)STRIP_FP(m->methodPointer);

        if (auto m = s_get_method_from_name(GameObject, "Find", 1))
            if (m->methodPointer) GO_Find = (t_GO_Find)STRIP_FP(m->methodPointer);
    }
    KITTY_LOGI("Unity resolver: GameObject=%p SetActive=%p GetComponent=%p GetComponentInChildren=%p",
               GameObject, (void*)GO_SetActive, (void*)GO_GetComponent, (void*)GO_GetComponentInChildren);

    Il2CppObject* ffind = GO_Find(CreateMonoString("App"));
    Il2CppObject* compone = GO_GetComponent(ffind, appStartupType);

    auto m_APIget_instance = s_get_method_from_name(AnimalCompanyAPI, "get_instance", 0);
    auto apiinstan   = (Il2CppObject*(*)())STRIP_FP(m_APIget_instance->methodPointer);

    CallSaveUserLoadoutTemplatesSlot1Empty(apiinstan());

    if (PrefabGenerator && s_get_method_from_name) {
        if (auto m = s_get_method_from_name(PrefabGenerator, "SpawnItem", 4))
            if (m->methodPointer) g_SpawnItem = (t_SpawnItem)STRIP_FP(m->methodPointer);
    }

    auto nm_get_instance_m = s_get_method_from_name(NetworkManager, "get_instance", 0);
    if (!nm_get_instance_m || !nm_get_instance_m->methodPointer) {
        KITTY_LOGI("NetworkManager.get_instance not found");
        return;
    }
    auto nm_get_instance = (Il2CppObject*(*)())STRIP_FP(nm_get_instance_m->methodPointer);
    do {
        nmInstance = nm_get_instance();
        sleep(2);
    } while (!nmInstance);

    if (nmInstance) {
        KITTY_LOGI("NetworkManager instance is not null");
    }

    auto nm_get_runner_m = s_get_method_from_name(NetworkManager, "get_currentRunner", 0);
    if (!nm_get_runner_m || !nm_get_runner_m->methodPointer) {
        KITTY_LOGI("NetworkManager.get_currentRunner not found");
        return;
    }
    auto nm_get_runner = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(nm_get_runner_m->methodPointer);

    auto nm_get_isRunning_m    = s_get_method_from_name(NetworkManager, "get_isRunning", 0);
    auto nm_get_isConnecting_m = s_get_method_from_name(NetworkManager, "get_isConnecting", 0);

    auto nm_get_isRunning = nm_get_isRunning_m && nm_get_isRunning_m->methodPointer
        ? (bool(*)(Il2CppObject*))STRIP_FP(nm_get_isRunning_m->methodPointer)
        : nullptr;

    auto nm_get_isConnecting = nm_get_isConnecting_m && nm_get_isConnecting_m->methodPointer
        ? (bool(*)(Il2CppObject*))STRIP_FP(nm_get_isConnecting_m->methodPointer)
        : nullptr;

    auto toUtf8 = [&](Il2CppString* s)->std::string {
        return il2cpp_string_to_std(s, string_chars, string_length);
    };
    auto objToString = [&](Il2CppObject* o)->std::string {
        if (!o) return {};
        Il2CppClass* k = s_object_get_class(o);
        auto m = s_get_method_from_name(k, "ToString", 0);
        if (!m || !m->methodPointer) return {};
        Il2CppException* ex = nullptr;
        auto str = (Il2CppString*)s_runtime_invoke(m, o, nullptr, &ex);
        return ex ? std::string() : toUtf8(str);
    };

    auto m_get_api = s_get_method_from_name(App, "get_apiSession", 0);
    if (!m_get_api) { NSLog(@"[Kitty] get_apiSession MethodInfo NOT found"); return; }
    if (!m_get_api->methodPointer) { NSLog(@"[Kitty] get_apiSession methodPointer is null"); return; }
    NSLog(@"[Kitty] get_apiSession method OK (static)");

    auto get_api = (Il2CppObject*(*)())STRIP_FP(m_get_api->methodPointer);

    Il2CppObject* iSession = nullptr;
    int tries11 = 0;
    do {
        iSession = get_api();
        if (!iSession) {
            NSLog(@"[Kitty] ISession is null (try %d) – waiting…", ++tries11);
            sleep(1);
        }
    } while (!iSession);
    NSLog(@"[Kitty] ISession acquired");

    if (!s_object_get_class) { NSLog(@"[Kitty] s_object_get_class is null"); return; }
    Il2CppClass* sessKlass = s_object_get_class(iSession);
    if (!sessKlass) { NSLog(@"[Kitty] ISession class resolve FAILED"); return; }
    NSLog(@"[Kitty] ISession class OK");

    auto m_toString = s_get_method_from_name(sessKlass, "ToString", 0);
    if (!m_toString) { NSLog(@"[Kitty] ToString MethodInfo NOT found"); return; }
    if (!m_toString->methodPointer) { NSLog(@"[Kitty] ToString methodPointer is null"); return; }
    NSLog(@"[Kitty] ToString method OK");

    if (!s_runtime_invoke) { NSLog(@"[Kitty] s_runtime_invoke is null"); return; }
    Il2CppException* ex = nullptr;
    auto sObj = (Il2CppString*)s_runtime_invoke(m_toString, iSession, nullptr, &ex);
    if (ex) { NSLog(@"[Kitty] ToString threw exception"); return; }
    if (!sObj) { NSLog(@"[Kitty] ToString returned null string"); return; }
    NSLog(@"[Kitty] ToString invoked OK");

    std::string s = il2cpp_string_to_std(sObj, string_chars, string_length);
    NSLog(@"[Kitty] ISession.ToString => %s", s.c_str());

    auto m_get_RefreshToken = s_get_method_from_name(Session, "get_RefreshToken", 0);
    auto get_RefreshToken = (Il2CppString*(*)(Il2CppObject*))STRIP_FP(m_get_RefreshToken->methodPointer);

    std::string refreshs = il2cpp_string_to_std(get_RefreshToken(iSession), string_chars, string_length);
    NSLog(@"[Kitty] ISession Refresh Token => %s", refreshs.c_str());
    
    int tries = 0;

    while (!runner)
    {
        nmInstance = nm_get_instance();
        if (!nmInstance) {
            KITTY_LOGI("NetworkManager instance null (try %d)", ++tries);
            sleep(2);
            continue;
        }

        runner = nm_get_runner(nmInstance);
        if (runner) break;

        bool connecting = nm_get_isConnecting ? nm_get_isConnecting(nmInstance) : false;
        bool running    = nm_get_isRunning    ? nm_get_isRunning(nmInstance)    : false;

        KITTY_LOGI("Fusion.NetworkRunner is null (try %d) [connecting=%d runn ing=%d]",
                   ++tries, (int)connecting, (int)running);
        sleep(2);
    }
    if(runner)
    {
        KITTY_LOGI("runner is not null");
    }

    auto m_getSession = s_get_method_from_name(NetworkRunner, "get_SessionInfo", 0);
    if (!m_getSession || !m_getSession->methodPointer) {
        NSLog(@"[Kitty] NetworkRunner.get_SessionInfo not found");
        return;
    }
    auto getSession = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(m_getSession->methodPointer);

    Il2CppObject* session = getSession(runner);
    if (!session) {
        NSLog(@"[Kitty] SessionInfo is null");
        return;
    }

    using t_get_string = Il2CppString* (*)(Il2CppObject*);

    Il2CppString* sName = nullptr;
    Il2CppString* sRegion = nullptr;
    Il2CppClass* kSession = s_object_get_class(session);

    auto m_getName = s_get_method_from_name(kSession, "get_Name", 0);
    if (m_getName && m_getName->methodPointer) {
        auto getName = (t_get_string)STRIP_FP(m_getName->methodPointer);
        sName = getName(session);
    } else {
        FieldInfo* fName = s_class_get_field_from_name(kSession, "Name");
        if (fName) s_field_get_value(session, fName, &sName);
    }

    if (!sName) {
        NSLog(@"[Kitty] SessionInfo.Name is null");
    } 

    auto m_getRegion = s_get_method_from_name(kSession, "get_Region", 0);
    if (m_getRegion && m_getRegion->methodPointer) {
        auto getRegion = (t_get_string)STRIP_FP(m_getRegion->methodPointer);
        sRegion = getRegion(session);
    } else {
        FieldInfo* fRegion = s_class_get_field_from_name(kSession, "Region");
        if (fRegion) s_field_get_value(session, fRegion, &sRegion);
    }

    if (!sRegion) {
        NSLog(@"[Kitty] SessionInfo.Region is null");
    }

    if (sName) {
        std::string name = toUtf8(sName);
        NSLog(@"[Kitty] Session name  : %s", name.c_str());
    }
    if (sRegion) {
        std::string region = toUtf8(sRegion);
        NSLog(@"[Kitty] Session region: %s", region.c_str());
    }

    auto m_getAuth = s_get_method_from_name(NetworkRunner, "get_AuthenticationValues", 0);
    auto getAuth   = (Il2CppObject*(*)(Il2CppObject*))STRIP_FP(m_getAuth->methodPointer);

    Il2CppObject* avs = nullptr;
    int trie2s = 0;
    do {
        avs = getAuth(runner);
        if (!avs) {
            KITTY_LOGI("AuthValues null (try %d). Waiting until after StartGame/connection…", ++trie2s);
            sleep(1);
        }
    } while (!avs);
    KITTY_LOGI("avs not null continue now");

    using t_get_string = Il2CppString* (*)(Il2CppObject*);
    using t_get_object = Il2CppObject* (*)(Il2CppObject*);
    using t_get_i32    = int32_t (*)(Il2CppObject*);

    auto m_GetParams = s_get_method_from_name(AuthenticationValues, "get_AuthGetParameters", 0);
    auto m_UserId    = s_get_method_from_name(AuthenticationValues, "get_UserId",            0);
    auto m_PostData  = s_get_method_from_name(AuthenticationValues, "get_AuthPostData",      0);
    auto m_Token     = s_get_method_from_name(AuthenticationValues, "get_Token",             0);
    auto m_AuthType  = s_get_method_from_name(AuthenticationValues, "get_AuthType",          0);
    if (!m_GetParams || !m_GetParams->methodPointer ||
        !m_UserId    || !m_UserId->methodPointer    ||
        !m_PostData  || !m_PostData->methodPointer  ||
        !m_Token     || !m_Token->methodPointer     ||
        !m_AuthType  || !m_AuthType->methodPointer) {
        return;
    }

    auto gp = (t_get_string)STRIP_FP(m_GetParams->methodPointer);
    auto ui = (t_get_string)STRIP_FP(m_UserId->methodPointer);
    auto pd = (t_get_object)STRIP_FP(m_PostData->methodPointer);
    auto tk = (t_get_object)STRIP_FP(m_Token->methodPointer);
    auto at = (t_get_i32   )STRIP_FP(m_AuthType->methodPointer);

    Il2CppString* sParams = gp(avs);
    Il2CppString* sUserId = ui(avs);
    Il2CppObject* oPost   = pd(avs);
    Il2CppObject* oToken  = tk(avs);
    int32_t       eType   = at(avs);

    const std::string params  = toUtf8(sParams);
    const std::string userId  = toUtf8(sUserId);
    const std::string postStr = objToString(oPost);
    const std::string tokStr  = objToString(oToken);

    NSLog(@"[Kitty] Auth Values | AuthGetParameters : %s", params.c_str());
    NSLog(@"[Kitty] Auth Values | UserId            : %s", userId.c_str());
    NSLog(@"[Kitty] Auth Values | AuthPostData      : %s", postStr.c_str());
    NSLog(@"[Kitty] Auth Values | Token             : %s", tokStr.c_str());
    NSLog(@"[Kitty] Auth Values | AuthType          : %d", (int)eType);
    
    if (!s_get_method_from_name) { NSLog(@"[Kitty] s_get_method_from_name is null"); return; }

    FieldInfo* fPhoton = s_class_get_field_from_name(NetworkManager, "_photonSettings");
    if (!fPhoton) {
        NSLog(@"[Kitty] _photonSettings field not found");
        return;
    }

    Il2CppObject* photonSettings = nullptr;
    s_field_get_value(nmInstance, fPhoton, &photonSettings);
    if (!photonSettings) {
        NSLog(@"[Kitty] _photonSettings is NULL");
        return;
    }

    Il2CppClass* kPhoton = s_object_get_class(photonSettings);
    FieldInfo* fAppSettings = s_class_get_field_from_name(kPhoton, "AppSettings");
    if (!fAppSettings) {
        NSLog(@"[Kitty] PhotonAppSettings.AppSettings field not found");
        return;
    }

    Il2CppObject* appSettings = nullptr;
    s_field_get_value(photonSettings, fAppSettings, &appSettings);
    if (!appSettings) {
        NSLog(@"[Kitty] PhotonAppSettings.AppSettings is NULL");
        return;
    }

    Il2CppClass* kApp = s_object_get_class(appSettings);

    MethodInfo* m_ToString = s_get_method_from_name(kApp, "ToString", 0);
    Il2CppString* sFull = nullptr;
    if (m_ToString && m_ToString->methodPointer) {
        Il2CppException* exss = nullptr;
        sFull = (Il2CppString*)s_runtime_invoke(m_ToString, appSettings, nullptr, &exss);
        if (exss) sFull = nullptr;
    } else {
        NSLog(@"[Kitty] AppSettings.ToString not found");
    }


    FieldInfo* f_AppIdFusion   = s_class_get_field_from_name(kApp, "AppIdFusion");
    FieldInfo* f_AppVersion    = s_class_get_field_from_name(kApp, "AppVersion");
    FieldInfo* f_BestRegion    = s_class_get_field_from_name(kApp, "FixedRegion");
    FieldInfo* f_AppIdRealtime = s_class_get_field_from_name(kApp, "AppIdRealtime");

    if (!f_AppIdFusion || !f_AppVersion || !f_BestRegion || !f_AppIdRealtime) {
        NSLog(@"[Kitty] one or more AppSettings fields are missing");
        return;
    }

    Il2CppString *sAppIdFusion   = nullptr;
    Il2CppString *sAppVersion    = nullptr;
    Il2CppString *sBestRegion    = nullptr;
    Il2CppString *sAppIdRealtime = nullptr;

    s_field_get_value(appSettings, f_AppIdFusion,   &sAppIdFusion);
    s_field_get_value(appSettings, f_AppVersion,    &sAppVersion);
    s_field_get_value(appSettings, f_BestRegion,    &sBestRegion);
    s_field_get_value(appSettings, f_AppIdRealtime, &sAppIdRealtime);

    std::string fullStr       = toUtf8(sFull);
    std::string appIdFusion   = toUtf8(sAppIdFusion);
    std::string appVersion    = toUtf8(sAppVersion);
    std::string bestRegion    = toUtf8(sBestRegion);
    std::string appIdRealtime = toUtf8(sAppIdRealtime);

    if (!sFull) {
        NSLog(@"[Kitty] AppSettings.ToString() is NULL");
    } else {
        NSLog(@"[Kitty] FusionAppSettings.ToString(): %s", fullStr.c_str());
    }

    NSLog(@"[Kitty] AppIdFusion   : %s", appIdFusion.c_str());
    NSLog(@"[Kitty] AppVersion    : %s", appVersion.c_str());
    NSLog(@"[Kitty] BestRegion    : %s", bestRegion.c_str());
    NSLog(@"[Kitty] AppIdRealtime : %s", appIdRealtime.c_str());

      NSLog(@"[Kitty] LogNakamaClient() start");

    Il2CppClass* apiKlass = classMap["AnimalCompany.API"]["AnimalCompanyAPI"];
    if (!apiKlass) {
        NSLog(@"[Kitty] AnimalCompanyAPI class not found in classMap");
        return;
    }
    NSLog(@"[Kitty] AnimalCompanyAPI class: %p", apiKlass);

    FieldInfo* fClient = s_class_get_field_from_name(apiKlass, "_client");
    if (!fClient) {
        NSLog(@"[Kitty] _client FieldInfo not found");
        return;
    }
    NSLog(@"[Kitty] _client FieldInfo: %p", fClient);

    Il2CppObject* clientObj = nullptr;

    if (s_field_static_get_value) {
        s_field_static_get_value(fClient, &clientObj);
        NSLog(@"[Kitty] s_field_static_get_value used, clientObj=%p", clientObj);
    } 
    else 
    {
        if (!apiKlass->static_fields) {
            NSLog(@"[Kitty] apiKlass->static_fields is NULL and no s_field_static_get_value");
            return;
        }
        memcpy(&clientObj,
               (char*)apiKlass->static_fields + fClient->offset,
               sizeof(Il2CppObject*));
        NSLog(@"[Kitty] static_fields fallback, clientObj=%p", clientObj);
    }

    if (!clientObj) {
        NSLog(@"[Kitty] _client is NULL (maybe not initialized yet)");
        return;
    }

    Il2CppClass* clientKlass = s_object_get_class(clientObj);
    if (!clientKlass) {
        NSLog(@"[Kitty] clientKlass is NULL");
        return;
    }
    NSLog(@"[Kitty] clientKlass=%p", clientKlass);
    MethodInfo* m_toStringClient = s_get_method_from_name(clientKlass, "ToString", 0);
    if (!m_toStringClient || !m_toStringClient->methodPointer) {
        NSLog(@"[Kitty] Client.ToString() method not found");
        return;
    }
    NSLog(@"[Kitty] Client.ToString MethodInfo=%p", m_toStringClient);
    Il2CppException* exClient = nullptr;
    Il2CppString* sClient =
        (Il2CppString*)s_runtime_invoke(m_toStringClient, clientObj, nullptr, &exClient);

    if (exClient) {
        NSLog(@"[Kitty] Client.ToString() threw an exception");
        return;
    }
    if (!sClient) {
        NSLog(@"[Kitty] Client.ToString() returned NULL");
        return;
    }
    std::string clientStr = il2cpp_string_to_std(sClient, string_chars, string_length);
    NSLog(@"[Kitty] AnimalCompanyAPI._client.ToString(): %s", clientStr.c_str());

    NSLog(@"[Kitty] LogNakamaClient() end");

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