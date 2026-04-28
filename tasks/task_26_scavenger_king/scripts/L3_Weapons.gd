extends RefCounted
class_name L3_Weapons


## SLING/BOW kept for legacy callers; UC-L3-15 names Gile / Tor explicitly.
enum Kind { SLING, BOW, RIFLE, GILE, TOR }


static func is_dimotfer_rifle(k: Kind) -> bool:
	return k == Kind.RIFLE


static func is_gile_or_tor(k: Kind) -> bool:
	return k == Kind.GILE or k == Kind.TOR or k == Kind.SLING or k == Kind.BOW


## Tor (throwing spear) — UC-L3-16 stagger; BOW maps to Tor for older call sites.
static func is_tor_throw(k: Kind) -> bool:
	return k == Kind.TOR or k == Kind.BOW
