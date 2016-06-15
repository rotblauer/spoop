module SpoopConstants
	VALID_EMAIL_REGEX = /\A([-a-z0-9!\#$%&'*+\/=?^_`{|}~]+\.)*[-a-z0-9!\#$%&'*+\/=?^_`{|}~]+@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
	HASHTAG_REGEX = /(?:\s|^)(?:#(?!\d+(?:\s|$)))(\w+)(?=\s|$|,|.|;|\?)/i
	LOG_MATCH_MINUTES_WINDOW = 10.minutes
end
