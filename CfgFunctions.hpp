class CfgFunctions
{
    class KBCF
    {
        tag = "KBCF";

        class Core
        {
            file = "src\Core";

            class init {};
            class scheduler {};
            class log {};
        };

        class Blackboard
        {
            file = "src\Blackboard";

            class createBlackboard {};
            class publishContact {};
            class queryContacts {};
            class getContact {};
            class reserveTarget {};
            class releaseTarget {};
            class updateContact {};
            class cleanupContacts {};
        };

        class AI
        {
            file = "src\AI";

            class classifyTarget {};
            class scoreTarget {};
            class selectTarget {};
            class evaluateThreat {};
            class predictPosition {};
            class validateAssignment {};
            class trackTarget {};
            class predictIntercept {};
        };

        class Commander
        {
            file = "src\Commander";

            class updateBattlefield {};
        };

        class Drones
        {
            file = "src\Drones";

            class assignTarget {};
            class executeAttack {};
            class processContact {};
            class reconScan {};
            class reassignTarget {};
        };
        
        class Planning
        {
            file = "src\Planning";

            class planAttack {};
            class executePlan {};
        };
    };
};