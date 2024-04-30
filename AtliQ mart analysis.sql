
-- 1. Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' 
-- (Buy One Get One Free).

select category,product_name from dim_products d
inner join fact_events f on f.product_code = d.product_code 
where base_price > 500 and promo_type = 'BOGOF'
group by 1,2;

-- products like atliq double bedsheet set and waterproof immersion rod are highly discounted with BOGOF and were initial base price greater than 500. 

-- 2. write a query that provides an overview of the number of stores in each city. 
-- The results will be sorted in descending order of store counts, 
-- allowing us to identify the cities with the highest store presence. 


select * from dim_stores;

select city,count(*) as stores from dim_stores
group by city
order by count(*) desc;

-- Bengaluru has the highest number of stores of 10 then chennai with 8 stores followed by Hyderabad with 7 stores.cities like
-- vijaywada,trivandrum,mangalore,mysure,madurai has stores less than 5.

-- 3. write a query that displays each campaign along with the total revenue generated before and after the campaign? 
-- The report includes three key fields: campaign_name, total_revenue(before_promotion), total_revenue(after_promotion). 

select * from fact_events;
select * from dim_campaigns;
select campaign_name,(base_price * qty_sold_before_promo) as revenue_before_promo,
(base_price * qty_sold_after_promo) as revenue_after_promo from fact_events f
left join dim_campaigns d on d.campaign_id = f.campaign_id 
group by campaign_name;

-- sanskranti has the highest revenue after promotion and diwali has the lowest revenue before promotion.More capital was generated
-- in diwali rather than sansktanti.

-- 4. Calculate the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. 
-- Additionally, provide rankings for the categories based on their ISU%. 
-- The report will include three key fields: category, isu%, and rank order. 
-- This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.

select * from fact_events;
select category,(qty_sold_after_promo/qty_sold_before_promo)*100 as percent,
dense_rank() over(order by (qty_sold_after_promo/qty_sold_before_promo)*100 desc) as rank_
from fact_events f
inner join dim_products d on d.product_code = f.product_code
inner join dim_campaigns c on c.campaign_id = f.campaign_id
where campaign_name = 'diwali'
group by category;

-- we can see Home Appliances has the highest percentage increase in revenue which is about 336 % foloowed by combo1 by 304 %. 
-- The least percentage increase in Grocery&Staples which is actually about of 82 %.

-- 5. What are the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. 
-- The report will provide essential information including product name, category, and ir%. 

select campaign_name,product_name,category,percent,rank_ from 
(select campaign_name,product_name,category,(base_price * qty_sold_after_promo) * 100 /(base_price * qty_sold_before_promo) as percent,
dense_rank() over(partition by campaign_name order by (base_price * qty_sold_after_promo) *100 /(base_price * qty_sold_before_promo) desc) 
as rank_
from fact_events f
inner join dim_products d on d.product_code = f.product_code
inner join dim_campaigns c on c.campaign_id = f.campaign_id
group by 1,2,3) x
where rank_ between 1 and 5;

-- In diwali campaign waterproof_immersion_rod from home appliances has the highest incremental increase in revenue by 400 %.
-- and sanskranti campaign farm_chakki_atta from grocery has the highest incremental increase in  revenue by 402 %.

-- we can observe that in diwali campaign customers are more intrested in buying home appliances and home care products. 
-- coming to sankranti campaign grocery and home care products are high in demand.home care products are always in demand irrespective
-- of campaign.
