function info= spheroApiRev1_50()
% SPHEROAPIREV1_50 Constants and parameters for Sphero Communication API Rev 1.50
%
% Copyright 2015, The MathWorks, Inc.
   
%% Device IDs
info.Constants.DidCore        = uint8(hex2dec('00'));
info.Constants.DidBootloader  = uint8(hex2dec('01'));
info.Constants.DidSphero      = uint8(hex2dec('02'));
        
%% Command IDs
% For Did = 0
info.Constants.CmdPing              = uint8(hex2dec('01'));
info.Constants.CmdVersion           = uint8(hex2dec('02'));
info.Constants.CmdControlUartTx     = uint8(hex2dec('03'));
info.Constants.CmdSetBtName         = uint8(hex2dec('10'));
info.Constants.CmdGetBtName         = uint8(hex2dec('11'));
info.Constants.CmdSetAutoReconnect  = uint8(hex2dec('12'));
info.Constants.CmdGetAutoReconnect  = uint8(hex2dec('13'));
info.Constants.CmdGetPwrState       = uint8(hex2dec('20'));
info.Constants.CmdSetPwrNotify      = uint8(hex2dec('21'));
info.Constants.CmdSleep             = uint8(hex2dec('22'));
info.Constants.GetPowerTrips        = uint8(hex2dec('23'));
info.Constants.SetPowerTrips        = uint8(hex2dec('24'));
info.Constants.SetInactiveTimer     = uint8(hex2dec('25'));
info.Constants.CmdGotoBl            = uint8(hex2dec('30'));
info.Constants.CmdRunL1Diags        = uint8(hex2dec('40'));
info.Constants.CmdRunL2Diags        = uint8(hex2dec('41'));
info.Constants.CmdClearCounters     = uint8(hex2dec('42'));
info.Constants.CmdAssignTime        = uint8(hex2dec('50'));
info.Constants.CmdPollTime          = uint8(hex2dec('51'));
        
% For Did = 1
info.Constants.BeginReflash         = uint8(hex2dec('02'));
info.Constants.HereIsPage           = uint8(hex2dec('03'));
info.Constants.LeaveBootloader      = uint8(hex2dec('04'));
info.Constants.IsPageBlank          = uint8(hex2dec('05'));
info.Constants.CmdEraseUserConfig   = uint8(hex2dec('06'));

% For Did = 2
info.Constants.CmdSetCal                = uint8(hex2dec('01'));
info.Constants.CmdSetStabiliz           = uint8(hex2dec('02'));
info.Constants.CmdSetRotationRate       = uint8(hex2dec('03'));
info.Constants.CmdSetCreationDate       = uint8(hex2dec('04'));
info.Constants.CmdGetChassisId          = uint8(hex2dec('07'));
info.Constants.CmdSetChassisId          = uint8(hex2dec('08'));
info.Constants.CmdSelfLevel             = uint8(hex2dec('09'));
info.Constants.CmdSetDataStreaming      = uint8(hex2dec('11'));
info.Constants.CmdSetCollisionDet       = uint8(hex2dec('12'));
info.Constants.CmdLocator               = uint8(hex2dec('13'));
info.Constants.CmdSetAccelero           = uint8(hex2dec('14'));
info.Constants.CmdReadLocator           = uint8(hex2dec('15'));
info.Constants.CmdSetRgbLed             = uint8(hex2dec('20'));
info.Constants.CmdSetBackLed            = uint8(hex2dec('21'));
info.Constants.CmdGetRgbLed             = uint8(hex2dec('22'));
info.Constants.CmdRoll                  = uint8(hex2dec('30'));
info.Constants.CmdBoost                 = uint8(hex2dec('31'));
info.Constants.CmdSetRawMotors          = uint8(hex2dec('33'));
info.Constants.CmdSetMotionTo           = uint8(hex2dec('34'));
info.Constants.CmdSetOptionsFlag        = uint8(hex2dec('35'));
info.Constants.CmdGetOptionsFlag        = uint8(hex2dec('36'));
info.Constants.CmdSetTempOptionsFlag    = uint8(hex2dec('37'));
info.Constants.CmdGetTempOptionsFlag    = uint8(hex2dec('38'));
info.Constants.CmdGetConfigBlk          = uint8(hex2dec('40'));
info.Constants.CmdSetSsbParams          = uint8(hex2dec('41'));
info.Constants.CmdSetDeviceMode         = uint8(hex2dec('42'));
info.Constants.CmdCdgBlock              = uint8(hex2dec('43'));
info.Constants.CmdGetDeviceMode         = uint8(hex2dec('44'));
info.Constants.CmdGetSsb                = uint8(hex2dec('46'));
info.Constants.CmdSetSsb                = uint8(hex2dec('47'));
info.Constants.CmdSsbRefill             = uint8(hex2dec('48'));
info.Constants.CmdSsbBuy                = uint8(hex2dec('49'));
info.Constants.CmdSsbUseConsumeable     = uint8(hex2dec('4A'));
info.Constants.CmdSsbGrantCores         = uint8(hex2dec('4B'));
info.Constants.CmdSsbAddXp              = uint8(hex2dec('4C'));
info.Constants.CmdSsbLevelUpAttr        = uint8(hex2dec('4D'));
info.Constants.CmdGetPwSeed             = uint8(hex2dec('4E'));
info.Constants.CmdSsbEnableAsync        = uint8(hex2dec('4F'));
info.Constants.CmdRunMacro              = uint8(hex2dec('50'));
info.Constants.CmdSaveTempMacro         = uint8(hex2dec('51'));
info.Constants.CmdSaveMacro             = uint8(hex2dec('52'));
info.Constants.CmdInitMacroExecutive    = uint8(hex2dec('54'));
info.Constants.CmdAbortMacro            = uint8(hex2dec('55'));
info.Constants.CmdMacroStatus           = uint8(hex2dec('56'));
info.Constants.CmdSetMacroParam         = uint8(hex2dec('57'));
info.Constants.CmdAppendTempMacroChunk  = uint8(hex2dec('58'));
info.Constants.CmdEraseOrbbas           = uint8(hex2dec('60'));
info.Constants.CmdAppendFrag            = uint8(hex2dec('61'));
info.Constants.CmdExecOrbbas            = uint8(hex2dec('62'));
info.Constants.CmdAbortOrbbas           = uint8(hex2dec('63'));
info.Constants.CmdAnswerInput           = uint8(hex2dec('64'));
info.Constants.CmdCommitToFlash         = uint8(hex2dec('65'));

%% Dlen for Commands sent to Sphero
% Did = 0
info.Constants.CmdPingDlen              = uint8(hex2dec('01'));
info.Constants.CmdVersionDlen           = uint8(hex2dec('01'));
info.Constants.CmdControlUartTxDlen     = uint8(hex2dec('02'));
info.Constants.CmdGetBtNameDlen         = uint8(hex2dec('01'));
info.Constants.CmdSetAutoReconnectDlen  = uint8(hex2dec('03'));
info.Constants.CmdGetAutoReconnectDlen  = uint8(hex2dec('01'));
info.Constants.CmdGetPwrStateDlen       = uint8(hex2dec('01'));
info.Constants.CmdSetPwrNotifyDlen      = uint8(hex2dec('02'));
info.Constants.CmdSleepDlen             = uint8(hex2dec('06'));
info.Constants.GetPowerTripsDlen        = uint8(hex2dec('01'));
info.Constants.SetPowerTripsDlen        = uint8(hex2dec('05'));
info.Constants.SetInactiveTimerDlen     = uint8(hex2dec('03'));
info.Constants.CmdGotoBlDlen            = uint8(hex2dec('01'));
info.Constants.CmdRunL1DiagsDlen        = uint8(hex2dec('01'));
info.Constants.CmdRunL2DiagsDlen        = uint8(hex2dec('01'));
info.Constants.CmdClearCountersDlen     = uint8(hex2dec('01'));
info.Constants.CmdAssignTimeDlen        = uint8(hex2dec('05'));
info.Constants.CmdPollTimeDlen          = uint8(hex2dec('05'));

% For Did = 2
info.Constants.CmdSetCalDlen                = uint8(hex2dec('03'));
info.Constants.CmdSetStabilizDlen           = uint8(hex2dec('02'));
info.Constants.CmdSetRotationRateDlen       = uint8(hex2dec('02'));
info.Constants.CmdSetCreationDateDlen       = uint8(hex2dec('21'));
info.Constants.CmdGetChassisIdDlen          = uint8(hex2dec('01'));
info.Constants.CmdSetChassisIdDlen          = uint8(hex2dec('03'));
info.Constants.CmdSelfLevelDlen             = uint8(hex2dec('05'));
info.Constants.CmdSetDataStreamingDlen      = uint8(hex2dec('0e'));
info.Constants.CmdSetCollisionDetDlen       = uint8(hex2dec('07'));
info.Constants.CmdLocatorDlen               = uint8(hex2dec('08'));
info.Constants.CmdSetAcceleroDlen           = uint8(hex2dec('02'));
info.Constants.CmdReadLocatorDlen           = uint8(hex2dec('01'));
info.Constants.CmdSetRgbLedDlen             = uint8(hex2dec('05'));
info.Constants.CmdSetBackLedDlen            = uint8(hex2dec('02'));
info.Constants.CmdGetRgbLedDlen             = uint8(hex2dec('01'));
info.Constants.CmdRollDlen                  = uint8(hex2dec('05'));
info.Constants.CmdBoostDlen                 = uint8(hex2dec('02'));
info.Constants.CmdSetRawMotorsDlen          = uint8(hex2dec('05'));
info.Constants.CmdSetMotionToDlen           = uint8(hex2dec('03'));
info.Constants.CmdSetOptionsFlagDlen        = uint8(hex2dec('05'));
info.Constants.CmdGetOptionsFlagDlen        = uint8(hex2dec('01'));
info.Constants.CmdSetTempOptionsFlagDlen    = uint8(hex2dec('05'));
info.Constants.CmdGetTempOptionsFlagDlen    = uint8(hex2dec('01'));
info.Constants.CmdGetConfigBlkDlen          = uint8(hex2dec('02'));
info.Constants.CmdSetSsbParamsDlen          = uint8(hex2dec('FF'));
info.Constants.CmdSetDeviceModeDlen         = uint8(hex2dec('02'));
info.Constants.CmdCdgBlockDlen              = uint8(hex2dec('FF'));
info.Constants.CmdGetDeviceModeDlen         = uint8(hex2dec('01'));
info.Constants.CmdGetSsbDlen                = uint8(hex2dec('01'));
info.Constants.CmdSetSsbDlen                = uint8(hex2dec('FF'));
info.Constants.CmdSsbRefillDlen             = uint8(hex2dec('02'));
info.Constants.CmdSsbBuyDlen                = uint8(hex2dec('03'));
info.Constants.CmdSsbUseConsumeableDlen     = uint8(hex2dec('02'));
info.Constants.CmdSsbGrantCoresDlen         = uint8(hex2dec('09'));
info.Constants.CmdSsbAddXpDlen              = uint8(hex2dec('06'));
info.Constants.CmdSsbLevelUpAttrDlen        = uint8(hex2dec('06'));
info.Constants.CmdGetPwSeedDlen             = uint8(hex2dec('01'));
info.Constants.CmdSsbEnableAsyncDlen        = uint8(hex2dec('02'));
info.Constants.CmdRunMacroDlen              = uint8(hex2dec('02'));
info.Constants.CmdInitMacroExecutiveDlen    = uint8(hex2dec('01'));
info.Constants.CmdAbortMacroDlen            = uint8(hex2dec('01'));
info.Constants.CmdMacroStatusDlen           = uint8(hex2dec('01'));
info.Constants.CmdSetMacroParamDlen         = uint8(hex2dec('04'));
info.Constants.CmdEraseOrbbasDlen           = uint8(hex2dec('02'));
info.Constants.CmdExecOrbbasDlen            = uint8(hex2dec('04'));
info.Constants.CmdAbortOrbbasDlen           = uint8(hex2dec('01'));
info.Constants.CmdAnswerInputDlen           = uint8(hex2dec('05'));
info.Constants.CmdCommitToFlashDlen         = uint8(hex2dec('01'));

%% Dlen of Response received from Sphero
% Dlen of Synchronous responses
info.Constants.RspVersionDlen = uint8(hex2dec('09'));
info.Constants.RspGetBtNameDlen = uint8(hex2dec('21'));
info.Constants.RspGetAutoReconnectDlen = uint8(hex2dec('03'));
info.Constants.RspGetPwrStateDlen = uint8(hex2dec('09'));
info.Constants.RspGetPowerTripsDlen = uint8(hex2dec('05'));
info.Constants.RspRunL2DiagsDlen = uint8(hex2dec('59'));
info.Constants.RspPollTimesDlen = uint8(hex2dec('0D'));
info.Constants.RspReadLocatorDlen = uint8(hex2dec('0B'));
info.Constants.RspGetRgbLedDlen = uint8(hex2dec('04'));
info.Constants.RspGetOptionsFlagDlen = uint8(hex2dec('05'));
info.Constants.RspGetTempOptionsFlagDlen = uint8(hex2dec('05'));
info.Constants.RspGetDeviceModeDlen = uint8(hex2dec('02'));
info.Constants.RspSsbRefillDlen = uint8(hex2dec('05'));
info.Constants.RspSsbBuyDlen = uint8(hex2dec('06'));
info.Constants.RspSsbUseConsumeableDlen = uint8(hex2dec('03'));
info.Constants.RspSsbGrantCoresDlen = uint8(hex2dec('05'));
info.Constants.RspSsbAddXpDlen = uint8(hex2dec('05'));
info.Constants.RspSsbLevelUpAttrDlen = uint8(hex2dec('05'));
info.Constants.RspGetPwSeedDlen = uint8(hex2dec('05'));
info.Constants.RspAbortMacroDlen = uint8(hex2dec('04'));
info.Constants.RspMacroStatusDlen = uint8(hex2dec('04'));

% Dlen of asynchronous responses
info.Constants.RspPowerDlen = uint8(hex2dec('02'));
info.Constants.RspPreSleepDlen = uint8(hex2dec('01'));
info.Constants.RspCollisionDlen = uint8(hex2dec('11'));
info.Constants.RspGyroAxisLimitDlen = uint8(hex2dec('01'));

info.Constants.RspSimpleDlen  = uint8(hex2dec('01'));
        
%% Message Response Codes        
info.Constants.RspCodeOk           = hex2dec('00');
info.Constants.RspCodeEgen         = hex2dec('01');
info.Constants.RspCodeEchksum      = hex2dec('02');
info.Constants.RspCodeEfrag        = hex2dec('03');
info.Constants.RspCodeEbadCmd      = hex2dec('04');
info.Constants.RspCodeEunsupp      = hex2dec('05');
info.Constants.RspCodeEbadMsg      = hex2dec('06');
info.Constants.RspCodeEparam       = hex2dec('07');
info.Constants.RspCodeEexec        = hex2dec('08');
info.Constants.RspCodeEbadDid      = hex2dec('09');
info.Constants.RspCodeMemBusy      = hex2dec('0A');
info.Constants.RspCodeBadPassword  = hex2dec('0B');
info.Constants.RspCodePowerNogood  = hex2dec('31');
info.Constants.RspCodePageIllegal  = hex2dec('32');
info.Constants.RspCodeFlashFail    = hex2dec('33');
info.Constants.RspCodeMaCorrupt    = hex2dec('34');
info.Constants.RspCodeMsgTimeout   = hex2dec('35');

% info.Constants.RspAsyncPower       = uint8(hex2dec('01'));
% info.Constants.RspAsyncL1Diag      = uint8(hex2dec('02'));        

%% Sequence of the asynchronous response that can be returned by Sphero
%Needs to be changed to a struct for code generation
info.Constants.RspAsync = {'power';
                            'level1diag';
                            'sensor';
                            'configblk';
                            'presleep';
                            'macro';
                            'collision';
                            'orbbasicprint';
                            'orbbasicerrorascii';
                            'orbbasicerrorbinary';
                            'selflevel';
                            'gyroaxislimit';
                            'ssb';
                            'levelup';
                            'shielddamage';
                            'xpupdate';
                            'boostupdate'};
                            
                            
%% Other constants        
info.Constants.expectedSop1        = uint8(hex2dec('FF'));
info.Constants.sop2Acknowledgement = uint8(hex2dec('FF'));
info.Constants.sop2Asynchronous    = uint8(hex2dec('FE'));
% info.Constants.seqAsynchronous     = uint8(hex2dec('00'));

%% Bit number for different parts of Sphero Response
info.SpheroResponse.sop1     = 1;
info.SpheroResponse.sop2     = 2;
info.SpheroResponse.mrsp     = 3;
info.SpheroResponse.seq      = 4;
info.SpheroResponse.dlen     = 5;
info.SpheroResponse.data     = 6;
info.SpheroResponse.chk      = 7;
info.SpheroResponse.idcode   = 3;
info.SpheroResponse.dlenmsb  = 4;
info.SpheroResponse.dlenlsb  = 5;
        
end
