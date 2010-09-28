/*
 * AppArmor security module
 *
 * This file contains AppArmor policy loading interface function definitions.
 *
 * Copyright (C) 1998-2008 Novell/SUSE
 * Copyright 2009-2010 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, version 2 of the
 * License.
 */

#ifndef __POLICY_INTERFACE_H
#define __POLICY_INTERFACE_H

struct aa_audit_iface {
	struct aa_audit base;

	const char *name;
	const char *name2;
	long pos;
};

int aa_audit_iface(struct aa_audit_iface *sa);
struct aa_profile *aa_unpack(void *udata, size_t size,
			     struct aa_audit_iface *sa);

#endif /* __POLICY_INTERFACE_H */
