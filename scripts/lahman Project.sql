
-- 1. What range of years for baseball games played does the provided database cover?
--range of years, baseball games, 

select * from teams

SELECT 
    MIN(yearid) AS first_year,
    MAX(yearid) AS last_year
FROM teams;


-- 2. Find the name and height of the shortest player in the database.
--How many games did he play in? What is the name of the team for which he played?

SELECT
    p.playerid,
    p.namefirst,
    p.namelast,
    p.height,
    t.teamid AS team_name,
    SUM(g) AS total_games
FROM people p
left join appearances a 
    ON p.playerid = a.playerid
left join teams t
    ON a.teamid = t.teamid
    AND a.yearid = t.yearid
where height =(select MIN(height) 
from people)
group by p.height,
       p.namelast,
	   p.namefirst,
	   p.playerid,
	   team_name
order by total_games


   
-- 3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
--player.people, schoolnames.school, salary,

-- from schools
-- where schoolname = 'Vanderbilt University'

-- select * from salaries
-- where lgid = 'AL'

select
       namefirst || '' || namelast as fullname,
	   sum(salary)::numeric::money as total_salary
from people
left join salaries
using (playerid)
join collegeplaying
using (playerid)
join schools
using(schoolid)
join managers
using(teamid)
where schoolname ilike '%Vanderbilt University%'
and salaries.lgid = 'AL'
group by 
         namefirst,
	     namelast
order by total_salary desc;



SELECT 
    namefirst,
    namelast,
    SUM(salary)::numeric::money AS total_salary
FROM people
inner join salaries 
using(playerid)
inner join collegeplaying
using(playerid)
inner join schools
using(schoolid)
WHERE schoolname = 'Vanderbilt University'
-- and lgid = 'NL'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;




-- 4. Using the fielding table, group players into three groups based on their position:
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three
--groups in 2016.

-- select * from fielding

SELECT 
    CASE 
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
        ELSE 'infield'
    END AS label_players,
	SUM(po) AS total_putouts,
	        yearid as year_2016
FROM fielding
where yearid = 2016
group by label_players, year_2016



-- SELECT 
-- CASE WHEN pos = 'OF' THEN 'Outfield'
-- 	 WHEN pos IN ('P', 'C') THEN 'Battery'
-- 	 ELSE 'Infield' END AS position,
-- 	 SUM(po) AS total_putouts
-- FROM fielding
-- WHERE yearid = 2016
-- GROUP BY position		 

   
-- 5. Find the average number of strikeouts per game by decade since 1920.
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. 
--Do you see any trends?

-- SELECT 
--     (yearid / 10) * 10 AS decade,
--     ROUND(SUM(so)::numeric / SUM(g), 2) AS avg_strikeouts_per_game
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade;

-- select round(avg(hr),2),
--        g as games
-- from teams
-- group by games;
   

SELECT 
    (yearid / 10) * 10 AS decade,
    ROUND(SUM(so)::numeric / SUM(g), 2) AS avg_strikeouts,
    ROUND(SUM(hr)::numeric / SUM(g), 2) AS avg_home_runs
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;



-- 6. Find the player who had the most success stealing bases in 2016,
--where __success__ is measured as the percentage of stolen base attempts
--which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted _at least_ 20 stolen bases.
	
select playerid,
	   namefirst || ' ' || namelast as fullname,
	   sb,
	   (sb + cs) as attempts,
	   round(100.0 * sb / (sb + cs), 2) as success_rate
from batting
join people
using(playerid)
where batting.yearid = 2016
and (sb + cs) >= 20
order by success_rate desc


-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series champion –
--determine why this is the case. Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
--What percentage of the time?
----------------------------------------------------------------------------------------------------
--From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
----------------------------------------------------------------------------------------------------
select MAX(wswin) AS max_win, 
		   yearid, 
		   teamid
from teams
where wswin = 'N'
and yearid between 1970 and 2016
GROUP BY yearid, teamid
ORDER BY max_win DESC

---------------------------------------------------------------------------------
--What is the smallest number of wins for a team that did win the world series? 
-----------------------------------------------------------------------------------

SELECT MIN(w) AS min_wins, 
		  yearid, 
		  teamid
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, teamid
ORDER BY min_wins ASC

-------------------------------------------------------------------------------------------
--Then redo your query, excluding the problem year.
-------------------------------------------------------------------------------------------
select MIN(wswin) as min_win,
          yearid,
          teamid	
from teams
where yearid between 1970 and 2016
and yearid <> 1981
and wswin = 'Y'
group by yearid, 
         teamid, 
		 yearid
order by min_win

----------------------------------------------------------------------------------------------------------
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
-----------------------------------------------------------------------------------------------------------
WITH top_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
    GROUP BY yearid
)
SELECT COUNT(*) AS years_top_team_won_ws
FROM teams t
JOIN top_wins tw 
  ON t.yearid = tw.yearid 
  AND t.w = tw.max_wins
WHERE t.wswin = 'Y';
------------------------------------------------------------------------------
--What percentage of the time?
------------------------------------------------------------------------------

WITH top_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
    GROUP BY yearid
),
top_win_ws AS (
    SELECT t.yearid
    FROM teams t
    JOIN top_wins tw
      ON t.yearid = tw.yearid
     AND t.w = tw.max_wins
    WHERE t.wswin = 'Y'
)
SELECT 
  COUNT(*) AS years_top_team_won_ws,
   2016 - 1970 + 1 AS total_years,
    ROUND(100.0 * COUNT(*) / (2016 - 1970 + 1), 2) AS percent_top_team_won_ws FROM top_win_ws;

	
-- SELECT 
-- 	(SELECT COUNT(*)
-- 	 FROM top_wins_teams
-- 	 WHERE wswin = 'N'
-- 	) * 100.0 /
-- 	(SELECT COUNT(*)
-- 	 FROM most_win_teams
-- 	);


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the 
--top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games).
--Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
--Repeat for the lowest 5 average attendance.

select * from homegames
select * from parks


SELECT 
	  park_name,
	  attendance,
      games,
      ROUND(SUM(attendance)::numeric / SUM(games), 0) AS avg_attendance_per_game
FROM homegames
JOIN parks
USING (park)
WHERE year = 2016
GROUP BY park_name,
	     attendance,
		 games
HAVING SUM(games) >= 10
ORDER BY avg_attendance_per_game DESC
LIMIT 5;



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL)
--and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

select * from awardsmanagers

select 
     namefirst || ' ' || namelast AS full_name,
	 yearid,
	 lgid,
	 name
from awardsmanagers
inner join people
using (playerid)
INNER JOIN managers
	USING(playerid,yearid,lgid)
inner join teams
using(teamid,yearid,lgid)
where awardid = 'TSN Manager of the Year'
and lgid in ('NL', 'AL')
group by full_name,yearid, lgid, name
having count(Distinct lgid) = 2
ORDER BY full_name;




SELECT 
    p.namefirst || ' ' || p.namelast AS full_name,
    STRING_AGG(t.name || ' (' || t.lgid || ')', ', ' ORDER BY a.yearid) AS teams_won
FROM awardsmanagers AS a
INNER JOIN people AS p
    USING(playerid)
INNER JOIN managers AS m
    USING(playerid, yearid, lgid)
INNER JOIN teams AS t
    USING(teamid, yearid, lgid)
WHERE a.awardid = 'TSN Manager of the Year'
  AND t.lgid IN ('NL', 'AL')
GROUP BY p.playerid, p.namefirst, p.namelast
HAVING COUNT(DISTINCT t.lgid) = 2
ORDER BY full_name;




-- 10. Find all players who hit their career highest number of home runs in 2016.
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016.
--Report the players' first and last names and the number of home runs they hit in 2016.

select playerid,
       namefirst || ' ' || namelast as full_name,
       max(r),
	   count(distinct yearid) as years_played,
	   lgid
from batting
join people
using(playerid)
where yearid >= 2016
-- and lgid < 10
group by playerid,
         lgid,
		 full_name
 

------------------------------------------------------------------------------------

SELECT 
    p.playerid,
	p.namefirst || ' ' || p.namelast AS full_name,
	max(r) as max_runs,
	lgid,
    COUNT(DISTINCT b.yearid) AS years_played,
    SUM(CASE WHEN b.yearid = 2016 THEN b.hr ELSE 0 END) AS home_runs_2016
FROM people p
JOIN batting b 
    ON p.playerid = b.playerid
GROUP BY p.playerid, full_name, lgid
HAVING COUNT(DISTINCT b.yearid) >= 10
   AND SUM(CASE WHEN b.yearid = 2016 THEN b.hr ELSE 0 END) >= 1
ORDER BY home_runs_2016 DESC;

----------------------------------------------------------------------------
select yearid
from batting
where yearid = 2016


-- SELECT 
--       namefirst || ' ' || namelast AS full_name,
--       yearid AS home_runs_2016
-- FROM batting
-- JOIN people AS p
--     ON batting.playerid = p.playerid
-- JOIN (
--     SELECT playerid, MAX(hr) AS max_hr
--     FROM batting
--     GROUP BY playerid
-- ) AS career_max
--     ON batting.playerid = career_max.playerid
--    AND batting.hr = career_max.max_hr
-- JOIN (
--     SELECT playerid
--     FROM batting
--     GROUP BY playerid
--     HAVING COUNT(DISTINCT yearid) >= 10
--        AND SUM(CASE WHEN yearid = 2016 THEN hr ELSE 0 END) >= 1
-- ) AS qualified
--     ON batting.playerid = qualified.playerid
-- WHERE batting.yearid = 2016
-- ORDER BY batting.hr DESC;




-- SELECT 
--     p.namefirst || ' ' || p.namelast AS full_name,
--     b2016.hr AS home_runs_2016
-- FROM batting AS b2016
-- JOIN people AS p
--     ON b2016.playerid = p.playerid
-- JOIN (
--     SELECT playerid, MAX(hr) AS max_hr
--     FROM batting
--     GROUP BY playerid
-- ) AS career_max
--     ON b2016.playerid = career_max.playerid
--    AND b2016.hr = career_max.max_hr
-- JOIN (
--     SELECT playerid
--     FROM batting
--     GROUP BY playerid
--     HAVING COUNT(DISTINCT yearid) >= 10
--        AND SUM(CASE WHEN yearid = 2016 THEN hr ELSE 0 END) >= 1
-- ) AS qualified
--     ON b2016.playerid = qualified.playerid
-- WHERE b2016.yearid = 2016
-- ORDER BY b2016.hr DESC;





-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? 
-- Use data from 2000 and later to answer this question. 
-- As you do this analysis, keep in mind that salaries across the whole league tend to increase together,
-- so you may want to look on a year-by-year basis.

select *
from salaries

select *
from teams


select
     SUM(salary)/1000000 AS earn_salary,
	  w as win_games,
	  teams.yearid as years_played,
	  teamid
from teams
inner join salaries
using(teamid)
WHERE salaries.yearid >= 2000
group by win_games, years_played, teamid 
order by years_played desc
limit 5


SELECT 
    teams.yearid,
    CORR(w, SUM(salary)) AS corr_wins_salary
FROM teams 
JOIN salaries 
  ON teams.teamid = salaries.teamid
 AND teams.yearid = salaries.yearid
WHERE teams.yearid >= 2000
GROUP BY yearid
ORDER BY yearid;



-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
