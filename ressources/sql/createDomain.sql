USE postfix;
CREATE TABLE `domaines` (
  `domaine` varchar(255) NOT NULL default '',
  `etat` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`domaine`)
) ENGINE=MyISAM;
CREATE TABLE `comptes` (
  `email` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `quota` int(10) NOT NULL default '0',
  `etat` tinyint(1) NOT NULL default '1',
  `imap` tinyint(1) NOT NULL default '1',
  `pop3` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`email`)
) ENGINE=MyISAM;
CREATE TABLE `alias` (
  `source` varchar(255) NOT NULL default '',
  `destination` text NOT NULL,
  `etat` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`source`)
) ENGINE=MyISAM;