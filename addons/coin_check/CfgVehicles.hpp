class CfgVehicles {
    class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
            class GVAR(coinCheck) {
                displayName = CSTRING(actionName);
                condition = QUOTE([ACE_player] call FUNC(canUseAction));
                statement = QUOTE([] call FUNC(activate));
                icon = "a3\ui_f\data\igui\cfg\actions\gear_ca.paa";
                showDisabled = 0;
                priority = 0;
            };
        };
    };

    class Box_NATO_Support_F;
    class GVAR(coinCrate): Box_NATO_Support_F {
        author = ECSTRING(main,Author);
        scope = 2;
        scopeCurator = 2;
        displayName = CSTRING(coinCrate_displayName);

        class TransportWeapons {};
        class TransportMagazines {};
        class TransportBackpacks {};
        class TransportItems {
            #include "crate.hpp"
        };
    };
};
