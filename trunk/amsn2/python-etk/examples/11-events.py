#!/usr/bin/python

import etk

w = etk.Window(title="Event example", size_request=(200, 200))
w.show_all()


def mouse_event(o, ev):
    print "%s -> pos: (%d, %d)" % (ev.__class__, ev.widget[0], ev.widget[1])
w.connect("mouse-in", mouse_event)
w.connect("mouse-out", mouse_event)

def mouse_event_updown(o, ev, click=False):
    if click:
        print "CLICK!"
    else:
        print "%s -> button: %d   pos: (%d, %d)" % (ev.__class__, ev.button, ev.widget[0], ev.widget[1])
w.connect("mouse-down", mouse_event_updown)
w.connect("mouse-up", mouse_event_updown)
w.connect("mouse-click", mouse_event_updown, True)

def mouse_event_move(o, ev):
    print "%s -> current pos: (%d, %d)" % (ev.__class__, ev.cur_widget[0], ev.cur_widget[1])
w.connect("mouse-move", mouse_event_move)

def mouse_event_wheel(o, ev):
    print "%s -> z: %d   pos: (%d, %d)" % (ev.__class__, ev.z, ev.widget[0], ev.widget[1])
w.connect("mouse-wheel", mouse_event_wheel)

def key_event(o, ev):
    print "%s -> key: %s" % (ev.__class__, ev.keyname)
w.connect("key-down", key_event)
w.connect("key-up", key_event)


def on_destroyed(obj):
    etk.main_quit()
w.connect("destroyed", on_destroyed)

etk.main()
