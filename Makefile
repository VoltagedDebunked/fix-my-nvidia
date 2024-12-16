# Declare phony target
.PHONY: all install uninstall

all:
	@echo "[i] Run 'sudo make install' to install Neo-fix-my-nvidia."

install:
	@mkdir -p /bin /usr/bin /usr/local/bin /usr/share/man/man1
	@cp nfixmynvidia /bin
	@cp nfixmynvidia /usr/bin
	@cp nfixmynvidia /usr/local/bin
	@cp nfixmynvidia.1 /usr/share/man/man1
	@chmod 755 /bin/nfixmynvidia /usr/bin/nfixmynvidia /usr/local/bin/nfixmynvidia
	@chmod 644 /usr/share/man/man1/nfixmynvidia.1
	@mandb
	@echo "[i] You have now finished installing neo-fix-my-nvidia."
	@echo "[i] Run 'sudo make uninstall to uninstall neo-fix-my-nvidia."

uninstall:
	@rm -rf /bin/nfixmynvidia /usr/bin/nfixmynvidia /usr/local/bin/nfixmynvidia /usr/share/man/man1/nfixmynvidia.1
	@mandb
	@echo "[i] You have now uninstalled neo-fix-my-nvidia."
	@echo "[i] Run 'sudo make install' to install neo-fix-my-nvidia."

