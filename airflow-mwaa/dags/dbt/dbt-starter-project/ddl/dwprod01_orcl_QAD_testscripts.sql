--from dwprod oracle - to run on the ORacle dwprod01
Select 'DW_COMMON__COST_TOTAL_DIMENSION -- '|| count(1) from 	DW_COMMON.COST_TOTAL_DIMENSION 
Union All Select 'DW_CUSTOM__BOM_EXPLODE --'|| count(1) from 	DW_CUSTOM.BOM_EXPLODE
Union All Select 'DW_STAGE__CM_MSTR   --'|| count(1) from 	DW_STAGE.CM_MSTR
Union All Select 'DW_STAGE__IDH_HIST  --'||count(1) from 	DW_STAGE.IDH_HIST
Union All Select 'DW_STAGE__IH_HIST   --'||count(1) from 	DW_STAGE.IH_HIST
Union All Select 'DW_STAGE__PI_MSTR   --'||count(1) from 	DW_STAGE.PI_MSTR
Union All Select 'DW_STAGE__POD_DET   --'||count(1) from 	DW_STAGE.POD_DET
Union All Select 'DW_STAGE__PO_MSTR   --'||count(1) from 	DW_STAGE.PO_MSTR
Union All Select 'DW_STAGE__PRH_HIST  --'||count(1) from 	DW_STAGE.PRH_HIST
Union All Select 'DW_STAGE__PS_MSTR   --'||count(1) from 	DW_STAGE.PS_MSTR
Union All Select 'DW_STAGE__PT_MSTR   --'||count(1) from 	DW_STAGE.PT_MSTR
Union All Select 'W_STAGE__SOD_DET    --'||count(1) from 	DW_STAGE.SOD_DET
Union All Select 'DW_STAGE__SO_MSTR   --'||count(1) from 	DW_STAGE.SO_MSTR
Union All Select 'DW_STAGE__SPT_DET   --'||count(1) from 	DW_STAGE.SPT_DET
Union All Select 'DW_STAGE__WOD_DET   --'||count(1) from 	DW_STAGE.WOD_DET
Union All Select 'DW_STAGE__WO_MSTR   --'||count(1) from 	DW_STAGE.WO_MSTR
Union All Select 'DW_STAGE__XXPT_MSTR --'||count(1) from 	DW_STAGE.XXPT_MSTR;

-- results
--DW_COMMON__COST_TOTAL_DIMENSION -- 1900844
--DW_CUSTOM__BOM_EXPLODE --1496407
--DW_STAGE__CM_MSTR   --99335
--DW_STAGE__IDH_HIST  --9037108
--DW_STAGE__IH_HIST   --2467468
--DW_STAGE__PI_MSTR   --1107694
--DW_STAGE__POD_DET   --403595
--DW_STAGE__PO_MSTR   --71931
--DW_STAGE__PRH_HIST  --1045890
--DW_STAGE__PS_MSTR   --989823
--DW_STAGE__PT_MSTR   --286162
--DW_STAGE__SOD_DET    --97007
--DW_STAGE__SO_MSTR   --0
--DW_STAGE__SPT_DET   --13948857
--DW_STAGE__WOD_DET   --3802918
--DW_STAGE__WO_MSTR   --1216454
--DW_STAGE__XXPT_MSTR --292671