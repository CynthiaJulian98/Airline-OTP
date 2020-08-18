SELECT 
EXTRACT(MONTH FROM flightdate) AS "month"
, td_day_of_week(flightdate) AS DoW
, marketingairline
, origin
, dest
, totalseatcount
, nautmiles
, EXTRACT(HOUR FROM out_) AS hour_out
, EXTRACT(HOUR FROM in_) AS hour_in
, airtime
, blockvariance
, depvariance
, divertedflag
, depdelayflag
, internationalflag
, origintemp
, originwindspeed
, CAST(CASE WHEN originwindgust = '-' THEN 0 ELSE originwindgust END AS INTEGER) AS originwindgust
, originvisibility
, originskycondition1
, CAST(CASE WHEN origincloudlevel1 = '-' THEN '40000' ELSE origincloudlevel1 END AS INTEGER) AS origincloudlevel1
, desttemp
, destwindspeed
 ,CAST(CASE WHEN destwindgust = '-' THEN 0 ELSE destwindgust END AS INTEGER) AS destwindgust
, destvisibility
, destskycondition1
, CAST(CASE WHEN destcloudlevel1 = '-' THEN '40000' ELSE destcloudlevel1 END AS INTEGER) AS destcloudlevel1
, acttimeongateorigin - schtimeongateorigin AS timeongatevariance
, arrvariance 
, CASE WHEN arrvariance > 0 THEN 1 ELSE 0 END AS late_flag 
, CASE WHEN arrvariance > 14 THEN 1 ELSE 0 END AS DOT_late_flag 
--mas.*,
/*flightdate
,td_day_of_week(flightdate) AS DoW
,marketingairline
,operatingairline
,flightno
,origin
,dest
,CASE WHEN origin < dest THEN origin||'-'||dest ELSE dest ||'-'||origin END AS market
,origintimezoneoffset
,desttimezoneoffset
,CAST(CASE WHEN nextdayflag = '1' THEN 1 ELSE 0 END AS INTEGER) AS nextdayflag
,totalseatcount
,premiumseatcount
,firstseatcount
,busseatcount
,ecoseatcount
,generalacft
,routing
,statmiles
,nautmiles
,depgate
,arrgate
,actualtailnumber
,out_
,off_
,on_
,in_
,airtime
,actualblocktime
,scheduledblocktime
,blockvariance
,taxiout
,taxiin
,depvariance
,arrvariance
,divertedflag
,cancelledflag
,taxiout30flag
,taxiout60flag
,taxiout90flag
,depdelayflag
,arrdelayflag
,blockzeroflag
,domesticflag
,internationalflag
,origintemp
,origindewpoint
,originwinddirection
,originwindspeed
,CAST(CASE WHEN originwindgust = '-' THEN 0 ELSE originwindgust END AS INTEGER) AS originwindgust
,originvisibility
,originwxstring
,originskycondition1
,origincloudlevel1
,originskycondition2
,origincloudlevel2
,originskycondition3
,origincloudlevel3
,desttemp
,destdewpoint
,destwinddirection
,destwindspeed
,destwindgust
,destvisibility
,destwxstring
,destskycondition1
,destcloudlevel1
,destskycondition2
,destcloudlevel2
,destskycondition3
,destcloudlevel3
,schbufforigin
,actbufforigin
,schbuffdest
,actbuffdest
,schtimeongateorigin
,acttimeongateorigin
,schtimeongatedest
,acttimeongatedest
,ronflag
,scheduledgatedeparturedatetime_zulu
,scheduledgatedeparturedatetime_zulu + CAST(origintimezoneoffset - 4 AS INTERVAL HOUR) AS scheduledDepartureLocal
,scheduledgatearrivaldatetime_zulu
,scheduledgatearrivaldatetime_zulu + CAST(desttimezoneoffset - 4 AS INTERVAL HOUR) AS scheduledDepartureLocal
,date_rec_added
,specificacft
,brakes_set_ts*/
FROM LAB_NP_MASFLIGHT.blk_masflight mas
WHERE 1=1
AND flightdate BETWEEN '2018-01-01' AND '2019-12-31'
AND marketingairline IN('AA', 'AS', 'B6', 'DL',  'F9', 'G4', 'HA', 'NK', 'SY', 'UA', 'WN')
AND origintimezoneoffset IS NOT NULL
AND desttimezoneoffset IS NOT NULL
AND out_ IS NOT NULL
AND off_ IS NOT NULL
AND on_ IS NOT NULL
AND in_ IS NOT NULL
AND airtime IS NOT NULL
AND actualblocktime IS NOT NULL
AND scheduledblocktime IS NOT NULL
AND ronflag IS NOT NULL
AND depgate IS NOT NULL
AND arrgate IS NOT NULL
AND acttimeongatedest IS NOT NULL
SAMPLE 200000