SELECT *
FROM users
LEFT JOIN roles
    ON users.user_role = roles.role
WHERE
    1 = 1
    AND user_id = $1
    AND roles.role IS NOT NULL