@echo off
if not exist z:\ ( subst z: new_Z )
py dec_test.py