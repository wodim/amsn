# -*- coding: utf-8 -*-
#
# Copyright (C) 2007 Johann Prieur <johann.prieur@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

__all__ = ["ContentRoamingError", "ContentRoamingState"]

class ContentRoamingError(object):
    UNKNOWN = 0

class ContentRoamingState(object):
    """Content roaming service synchronization state.

    The service is said to be synchronized when it
    matches the stuff stored on the server."""

    NOT_SYNCHRONIZED = 0
    """The service is not synchronized yet"""
    SYNCHRONIZING = 1
    """The service is being synchronized"""
    SYNCHRONIZED = 2
    """The service is already synchronized"""

