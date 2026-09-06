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
        };

        class AI
        {
            file = "src\AI";

            class classifyTarget {};
            class scoreTarget {};
            class selectTarget {};
        };
    };  
    

};