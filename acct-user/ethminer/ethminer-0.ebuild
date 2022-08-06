# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

ACCT_USER_ID=-1
ACCT_USER_GROUPS=( ethminer )
ACCT_USER_HOME="/var/lib/${PN}"
ACCT_USER_HOME_PERMS=0750

DESCRIPTION="user for ethminer daemon"

acct-user_add_deps

KEYWORDS="~amd64 ~x86"
