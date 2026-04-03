DESC gaming_and_mental_health;

SELECT *
FROM gaming_and_mental_health;

SELECT  round(count(*) / (SELECT count(*) FROM gaming_and_mental_health) * 100, 2) AS percentage_of_missing_values
FROM gaming_and_mental_health
WHERE grades_gpa = '';

SELECT round(count(*) / (SELECT count(*) FROM gaming_and_mental_health) * 100, 2) AS percentage_of_missing_values
FROM gaming_and_mental_health
WHERE work_productivity_score = '';

ALTER TABLE gaming_and_mental_health
DROP COLUMN grades_gpa,
DROP COLUMN work_productivity_score;

SELECT *
FROM gaming_and_mental_health;


UPDATE gaming_and_mental_health
SET withdrawal_symptoms = CASE WHEN withdrawal_symptoms = 'TRUE' THEN 'YES' ELSE 'NO' END,
loss_of_other_interests = CASE WHEN loss_of_other_interests = 'TRUE' THEN 'YES' ELSE 'NO' END,
continued_despite_problems = CASE WHEN continued_despite_problems = 'TRUE' THEN 'YES' ELSE 'NO' END,
eye_strain = CASE WHEN eye_strain = 'TRUE' THEN 'YES' ELSE 'NO' END,
back_neck_pain = CASE WHEN back_neck_pain = 'TRUE' THEN 'YES' ELSE 'NO' END;  

SELECT *
FROM gaming_and_mental_health; 

-- 1. Distribution of players across age groups --
-- creating age group column --

ALTER TABLE gaming_and_mental_health
ADD age_group VARCHAR(50)
AFTER age;

UPDATE gaming_and_mental_health
SET age_group = CASE WHEN age <= 14 THEN 'Children'
					 WHEN age <= 29 THEN 'Young Adults'
                     WHEN age <= 44 THEN 'Adults'
                     ELSE 'Elderly'
                     END;
                     
SELECT age_group, ROUND(COUNT(*)/(SELECT COUNT(*)
FROM gaming_and_mental_health)*100, 2) AS percentage_of_players
FROM gaming_and_mental_health
GROUP BY age_group;

-- 2. Percentage of players by gender --

SELECT gender, ROUND(COUNT(*)/(SELECT COUNT(*)
FROM gaming_and_mental_health)* 100, 2) AS percentage_of_players
FROM gaming_and_mental_health
GROUP BY gender;
                 
-- 3. The effects of daily playtime on back and neck health --

SELECT back_neck_pain, ROUND(AVG(daily_gaming_hours), 2) AS avg_playtime
FROM gaming_and_mental_health
GROUP BY back_neck_pain;

-- categorizing daily gaming hours --

ALTER TABLE gaming_and_mental_health
ADD daily_gaming_hours_category VARCHAR(50)
AFTER daily_gaming_hours;
                
UPDATE gaming_and_mental_health
SET daily_gaming_hours_category = CASE WHEN daily_gaming_hours <= 1 THEN 'Casual'
									   WHEN daily_gaming_hours <= 3 THEN 'Moderate'
                                       WHEN daily_gaming_hours <= 5 THEN 'High'
                                       ELSE 'Excessive'
                                       END;
                                       
-- 4. Average weight change for each category of daily playtime --

SELECT daily_gaming_hours_category AS playtime_category,
ROUND(AVG(weight_change_kg), 2) AS avg_weight_change
FROM gaming_and_mental_health
GROUP BY daily_gaming_hours_category
ORDER BY avg_weight_change;

-- 5. The number of players with eye strain for each category of daily playtime --

SELECT DISTINCT g.daily_gaming_hours_category AS playtime_category, 
COALESCE(Number_of_players, 0) AS number_of_players_with_eye_strain
FROM (
SELECT daily_gaming_hours_category, COUNT(*) AS Number_of_players
FROM gaming_and_mental_health
WHERE eye_strain = 'YES'
GROUP BY daily_gaming_hours_category) sub
RIGHT JOIN gaming_and_mental_health g 
ON sub.daily_gaming_hours_category = g.daily_gaming_hours_category
ORDER BY number_of_players_with_eye_strain DESC;

-- 6. The impact of different gaming platforms on the eyes -- 

SELECT gaming_platform, COUNT(*) AS number_of_players
FROM gaming_and_mental_health
WHERE eye_strain = 'YES'
GROUP BY gaming_platform
ORDER BY number_of_players DESC;

-- 7. The relationship between sleep quality and daily playtime --

SELECT sleep_quality, ROUND(AVG(daily_gaming_hours), 2) AS avg_daily_playtime
FROM gaming_and_mental_health
GROUP BY sleep_quality
ORDER BY avg_daily_playtime DESC;

-- 8. The relationship between daily playtime and sleep duration --

SELECT daily_gaming_hours_category AS playtime_category, ROUND(AVG(sleep_hours), 2) AS avg_sleeptime
FROM gaming_and_mental_health
GROUP BY daily_gaming_hours_category
ORDER BY avg_sleeptime;

-- 9. 3 Common mood states linked to continued risky gaming --

WITH cte AS (
SELECT *
FROM gaming_and_mental_health
WHERE continued_despite_problems = 'YES'
AND gaming_addiction_risk_level = 'Severe')
SELECT mood_state, ROUND(COUNT(*)/(SELECT COUNT(*) FROM cte) * 100 , 2)
AS percentage_of_players
FROM cte
GROUP BY mood_state
ORDER BY percentage_of_players DESC
LIMIT 3;

-- 10. The relationship of daily playtime, sleep duration and gaming addiction risk level --

SELECT gaming_addiction_risk_level, ROUND(AVG(daily_gaming_hours), 2) AS avg_daily_playtime,
ROUND(AVG(sleep_hours), 2) AS avg_sleep_time
FROM gaming_and_mental_health
GROUP BY gaming_addiction_risk_level
ORDER BY avg_daily_playtime DESC;

-- 11. The top 3 game genres that cause severe addiction --

WITH cte AS (
SELECT *
FROM gaming_and_mental_health 
WHERE gaming_addiction_risk_level = 'Severe')
SELECT game_genre, ROUND(COUNT(*)/(SELECT COUNT(*) FROM cte) * 100, 2) AS percentage_of_players
FROM cte
GROUP BY game_genre
ORDER BY percentage_of_players DESC
LIMIT 3;

-- 12. The top 3 game genres with the highest percentage of anxious players --

WITH cte AS (
SELECT *
FROM gaming_and_mental_health
WHERE mood_state = 'Anxious')
SELECT game_genre, ROUND(COUNT(*)/(SELECT COUNT(*) FROM cte)* 100, 2) AS percentage_of_players
FROM cte
GROUP BY game_genre
ORDER BY percentage_of_players DESC
LIMIT 3;

-- 13. The top 3 game genres known for causing high emotional instability --

WITH cte AS (
SELECT *
FROM gaming_and_mental_health
WHERE mood_swing_frequency = 'Daily')
SELECT game_genre, ROUND(COUNT(*) / (SELECT COUNT(*) FROM cte) * 100, 2) AS percentage_of_players
FROM cte
GROUP BY game_genre
ORDER BY percentage_of_players DESC
LIMIT 3;

-- 14. The impact of daily playtime, sleep duration on the academic performance --

SELECT academic_work_performance, ROUND(AVG(daily_gaming_hours), 2) AS avg_daily_playtime,
ROUND(AVG(sleep_hours), 2) AS avg_sleeptime
FROM gaming_and_mental_health
GROUP BY academic_work_performance
ORDER BY avg_daily_playtime DESC;

-- 15. The impact of long playtime on the loss of other interests --

SELECT loss_of_other_interests, ROUND(AVG(daily_gaming_hours), 2) AS avg_playtime
FROM gaming_and_mental_health
GROUP BY loss_of_other_interests
ORDER BY avg_playtime DESC;

-- 16. 3 mental states driven by excessive daily gaming playtime --

WITH cte AS (
SELECT *
FROM gaming_and_mental_health
WHERE daily_gaming_hours_category = 'EXCESSIVE')
SELECT mood_state, ROUND(COUNT(*)/ (SELECT count(*) FROM cte) * 100, 2) AS percentage_of_players
FROM cte
GROUP BY mood_state
ORDER BY percentage_of_players DESC
LIMIT 3;

-- categorizing social isolation score --

ALTER TABLE gaming_and_mental_health
ADD social_isolation_category VARCHAR(50)
AFTER social_isolation_score;
                
UPDATE gaming_and_mental_health
SET social_isolation_category = CASE WHEN social_isolation_score <= 3 THEN 'Low'
									 WHEN social_isolation_score <= 7 THEN 'Moderate'
									 ELSE 'High'
									 END;

-- 17. Average daily gaming hours and most common mood across social isolation categories --

WITH cte AS (
SELECT g.social_isolation_category, mood_state, avg_playtime, DENSE_RANK() OVER 
(PARTITION BY social_isolation_category ORDER BY count(*) DESC) AS rn
FROM gaming_and_mental_health g
JOIN (SELECT social_isolation_category, ROUND(AVG(daily_gaming_hours) ,2) AS avg_playtime
FROM gaming_and_mental_health
GROUP BY social_isolation_category) s on g.social_isolation_category = s.social_isolation_category
GROUP BY social_isolation_category, mood_state)
SELECT social_isolation_category, avg_playtime, mood_state AS most_common_mood
FROM cte 
WHERE rn = 1
ORDER BY avg_playtime DESC;

-- 18. The effect of weekly exercise duration on withdrawal severity --
 
SELECT withdrawal_symptoms, ROUND(AVG(exercise_hours_weekly), 2) AS avg_exercise_hours
FROM  gaming_and_mental_health
GROUP BY withdrawal_symptoms;

