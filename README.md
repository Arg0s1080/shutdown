# shutdown
A simple bash script for scheduling shutdowns, restarts, suspensions, etc on Linux systems with systemd, usually without root permissions

#### Usage:
    shutdown {-r | -s | -h | -y} [-t TIME]

    Options:
      -p  --poweroff        Shutdown the system
      -r  --reboot          Shutdown and reboot the system
      -s  --suspend         Suspend the system
      -h  --hybernate       Hybernate the system
      -y  --hybrid-sleep    Hibernate and suspend the system

      -t                    Start a countdown

      Notes:
        - If no param "-p" will be used by default.
          So: shutdown -t 1h == shutdown -p -t 1h
        
        - TIME must be expressed with the following suffixes:
          s=seconds, m=minutes, h=hours, d=days

    Examples:
    shutdown -t 2h  # Shutdown the system after 2 hours
    shutdown -s -t 20m #Suspend the system after 20 minutes
