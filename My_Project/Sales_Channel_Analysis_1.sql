SELECT
pv.sales_channel,
SUM(revenue_euro) as total_revenue,
COUNT(ticket_type) as total_tickets_sold
FROM 
passenger_validations as pv
WHERE 
ticket_type NOT LIKE '%Deutschlandticket%'
AND revenue_euro IS NOT NULL
GROUP BY pv.sales_channel 
ORDER BY total_revenue DESC;

/*
┌────────────────┬───────────────┬────────────────────┐
│ sales_channel  │ total_revenue │ total_tickets_sold │
│    varchar     │ decimal(38,2) │       int64        │
├────────────────┼───────────────┼────────────────────┤
│ DB Navigator   │      80308.80 │              13384 │
│ Ticket Machine │      80020.80 │              13292 │
│ HVV Switch App │      79209.60 │              13244 │
└────────────────┴───────────────┴────────────────────┘
Balanced Revenue Stream: The revenue distribution is remarkably 
balanced across all three channels (DB Navigator, Ticket Machine, 
and HVV Switch App), each generating approximately €79k–€80k and 
selling around 13,000 tickets.
Digital vs. Physical: While digital channels combined (DB Navigator
 + HVV Switch App) generate the majority of the revenue, physical Ticket 
 Machines remain extremely relevant, performing on par with top digital apps.
 Business Recommendation: The current omnichannel distribution strategy 
 is highly effective. The company should continue maintaining physical ticket
  machines at stations, as a significant portion of paying customers still relies
   on them for single and daily ticket purchases.
*/