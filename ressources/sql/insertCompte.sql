INSERT INTO `comptes` ( `email` , `password` , `quota` , `etat` , `imap` , `pop3` ) VALUES
('contact@votresite.com', ENCRYPT( 'votremotdepasse' ) , '0', '1', '1', '1');