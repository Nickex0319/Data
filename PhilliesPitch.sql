--1a AVG Pitches Per At Bat
SELECT AVG(1.00*pitch_number) as Average_Number_of_Pitches_Per_At_Bat
From PhilliesPitching.dbo.LastPitchPhillies
--AVG num of pitches per at bat is 3.89



--1b AVG Pitches Per At Bat Home Vs Away
SELECT 'Home' as TypeofGame, AVG(1.00*pitch_number) as AVG_Num_Pitches
From PhilliesPitching.dbo.LastPitchPhillies
WHERE home_team = 'PHI'
UNION
SELECT 'Away' as TypeofGame, AVG(1.00*pitch_number) as AVG_Num_Pitches
From PhilliesPitching.dbo.LastPitchPhillies
WHERE away_team = 'PHI'
--Phillies throw more pitches per at bat when they are at home




--1c AVG Pitches Per At Bat Lefty Vs Righty
SELECT 
AVG(CASE WHEN batter_position = 'L' THEN 1.00*pitch_number END) as AVG_Pitches_Lefty,
AVG(CASE WHEN batter_position = 'R' THEN 1.00*pitch_number END) as AVG_Pitches_Righty
From PhilliesPitching.dbo.LastPitchPhillies
--AVG Num Pitches for Lefties is lower than Righties





--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team 
SELECT DISTINCT home_team, p_position, AVG(1.00 * pitch_number) OVER (Partition by home_team, p_position) as AVG_Num_Pitches
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE away_team = 'PHI'
ORDER BY AVG_Num_Pitches
--Vs SD when PHI are away our Lefties throw the least amount of pitches per at bat
--VS TEX when PHI are away our Righties throw the most pitches per at bat
--The 3 highest avg num of pitches when PHI are away are Righties
--The 3 lowest avg num of pitches when PHI are away are Lefties











--1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts 
with pitchseq as (
SELECT DISTINCT
	pitch_name,
	pitch_number,
	count(pitch_name) OVER (Partition by pitch_name, pitch_number) as PitchFrequency
FROM PhilliesPitching.dbo.LastPitchPhillies 
WHERE pitch_number < 11
), 
pitchfreqrank as (SELECT * ,
rank() OVER (partition by pitch_number order by PitchFrequency DESC) PitchFrequencyRanking
FROM pitchseq)

SELECT * FROM pitchfreqrank WHERE PitchFrequencyRanking < 4
--PHI pitch regardless of the pitch number is 4-seam, slider, sinker




--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending
SELECT b.Name, AVG(1.00 * a.pitch_number)  as AVGPitches
FROM PhilliesPitching.dbo.LastPitchPhillies as a
LEFT JOIN PhilliesPitching.dbo.PhilliesPitchingStats as b ON b.pitcher = a.pitcher
WHERE b.IP >= 20
GROUP BY b.Name
ORDER BY AVG(1.00 * a.pitch_number) DESC
--Our elite pitchers/aces have the least amount of pitches thrown
--Though this is not indicative of success because they could just be getting hit off at a low count





--2a Count of the Last Pitches Thrown in Desc Order
SELECT pitch_name, COUNT(pitch_name) as count
FROM PhilliesPitching.dbo.LastPitchPhillies
GROUP BY pitch_name
ORDER BY count DESC
--4-Seam Fastball (2424), Sinker (2383), Slider (1470)


--2b Count of the different last pitches Fastball or Offspeed 
SELECT 
SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Fastball,
SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Offspeed
FROM PhilliesPitching.dbo.LastPitchPhillies
--Fastball (3116), Offspeed (6050)



--Count of the different last pitches Fastball or Offspeed when its a strikeout
SELECT 
SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Fastball,
SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Offspeed
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'strikeout'
--Offspeed is used to end the strikeout



--Count of the different last pitches Fastball or Offspeed when its a HR
SELECT 
SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Fastball,
SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) as Offspeed
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'home_run'
--Fastball (98), Offspeed (142)







--2c Percentage of the different last pitches Fastball or Offspeed 
SELECT 
100*SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END)/COUNT(pitch_name) as 'Fastball %',
100*SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END)/COUNT(pitch_name) as 'Offspeed %'
FROM PhilliesPitching.dbo.LastPitchPhillies
--66% of last pitches are offspeed



--2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher
WITH T1 AS (
SELECT sav.POS, ref.pitch_name, count(ref.pitch_name) as times_thrown
FROM PhilliesPitching.dbo.lastPitchPhillies as ref
JOIN PhilliesPitching.dbo.PhilliesPitchingStats as sav ON sav.pitcher = ref.pitcher
GROUP BY sav.POS, ref.pitch_name
),

T2 AS (
SELECT *, rank() OVER (partition by POS ORDER BY times_thrown DESC) as pitch_rank
FROM T1
)

SELECT * 
FROM T2
WHERE pitch_rank < 6
--SP utilize the sinker way more than RP









--3a What pitches have given up the most HRs 
SELECT pitch_name, COUNT(*) as HRCount
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'home_run'
GROUP BY pitch_name ORDER BY HRCount DESC





--3b Show HRs given up by zone and pitch, show top 5 most common
SELECT TOP 5 pitch_name, zone, COUNT(pitch_name) as HRCount
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'home_run'
GROUP BY zone, pitch_name ORDER BY HRCount DESC 
--No surprise highest HR count is fastballs that are straight down the middle or middle high














--3c Show HRs for each count type -> Balls/Strikes
SELECT balls, strikes, COUNT(*) as HRCount
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'home_run'
GROUP BY balls, strikes ORDER BY HRCount DESC
--0-0 counts give up HRs the most
--3-0 give up least, probably because batters are told to take that pitch






--3d Show Each Pitchers Most Common count to give up a HR
with T1 as (
SELECT player_name, balls, strikes, COUNT(*) as HRCount
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE events = 'home_run'
GROUP BY player_name, balls, strikes
),
T2 as (
SELECT *, rank() OVER (partition by player_name ORDER BY HRCount DESC) as HRRank
FROM T1
)

SELECT player_name, balls, strikes, HRCount FROM T2 WHERE HRRank < 2 
-- Seems like Nola gives up a lot on 0-0 (7)
-- Brogdon gives up HR late in the count
















--4a AVG Release speed, spin rate, strikeouts for Nola
SELECT 
	ROUND(AVG(release_speed),2) AvgReleaseSpeed,
	AVG(release_spin_rate) AvgSpinRate,
	Sum(case when events = 'strikeout' then 1 else 0 end) strikeouts
	
FROM PhilliesPitching.Dbo.LastPitchPhillies 
where player_name = 'Nola, Aaron'


--AVG RELEASE OF ALL PITCHERS
SELECT AVG(release_spin_rate) as AVG_Spin, player_name
FROM PhilliesPitching.dbo.LastPitchPhillies
GROUP BY player_name ORDER BY AVG_Spin DESC


--4b top pitches for each infield position where total pitches are over 5, rank them
with hitlocation as (
SELECT pitch_name, count(*) as times_hit, 'Pitcher' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 1 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
UNION
SELECT pitch_name, count(*) as times_hit, 'Catcher' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 2 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
UNION
SELECT pitch_name, count(*) as times_hit, 'First' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 3 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
UNION
SELECT pitch_name, count(*) as times_hit, 'Second' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 4 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
UNION
SELECT pitch_name, count(*) as times_hit, 'Third' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 5 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
UNION
SELECT pitch_name, count(*) as times_hit, 'Shortstop' as Position 
FROM PhilliesPitching.Dbo.LastPitchPhillies 
WHERE hit_location = 6 AND player_name = 'Nola, Aaron' 
GROUP BY pitch_name
)

SELECT *
FROM hitlocation
WHERE times_hit > 5
ORDER BY Position, times_hit DESC




--4c Show different balls/strikes as well as frequency when someone is on base 
SELECT balls, strikes, count(*) frequency
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE (on_3b is NOT NULL or on_2b is NOT NULL or on_1b is NOT NULL)
and player_name = 'Nola, Aaron'
group by balls, strikes
order by count(*) desc








--4d What pitch causes the lowest launch speed
SELECT TOP 1 pitch_name, AVG(launch_speed) as launch_speed
FROM PhilliesPitching.dbo.LastPitchPhillies
WHERE player_name = 'Nola, Aaron'
GROUP BY pitch_name ORDER BY AVG(launch_speed) ASC
--Changeup




