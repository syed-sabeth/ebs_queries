SELECT year(cast(MMT.transaction_date as date)) as YEAR,
	   month(cast(MMT.transaction_date as date)) as MONTH,
	   MMT.organization_id as ORG_ID,
	   MMT.inventory_item_id as INVENTORY_ITEM_ID,
	   -- MIC.segment2 as PRODUCT,
	   -- MIC.segment5 as MODEL,
	   -- (select segment2 from iceberg.ebs_12_2_5.inv___mtl_item_categories where category_set_id = 1 and organization_id = MMT.organization_id and inventory_item_id = MMT.inventory_item_id) PRODUCT,
	   -- (select segment5 from iceberg.ebs_12_2_5.inv___mtl_item_categories where category_set_id = 1100000041 and organization_id = MMT.organization_id and inventory_item_id = MMT.inventory_item_id) MODEL,
	   MSI.segment1 as ITEM_CODE,
	   MSI.description as ITEM_NAME,
	   SUM(MMT.primary_quantity) as PRODUCTION_QTY
	   from iceberg.ebs_12_2_5.inv___mtl_system_items_b MSI inner join iceberg.ebs_12_2_5.inv___mtl_material_transactions MMT 
	   on MSI.inventory_item_id = MMT.inventory_item_id and MSI.organization_id = MMT.organization_id 
	   inner join iceberg.ebs_12_2_5.apps___org_organization_definitions OD on MMT.organization_id = OD.organization_id 
	   where MSI.item_type = 'FG'
	   and OD.operating_unit in (203, 583)
	   and MMT.transaction_type_id in (44, 17)
	   and cast(MMT.transaction_date as date) > cast('2019-12-31' as date)
	   group by year(cast(MMT.transaction_date as date)), month(cast(MMT.transaction_date as date)), MMT.organization_id, MMT.inventory_item_id, MSI.segment1, MSI.description
	   order by year(cast(MMT.transaction_date as date)), month(cast(MMT.transaction_date as date)), MMT.organization_id, MMT.inventory_item_id, MSI.segment1, MSI.description
	   
