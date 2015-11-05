# Administrative Tool

## Authors
* Hojoon Lee

## Purpose
* To manage my computer from anywhere.

## Features
* Take a screenshot of PCs.
* Turn off.
* Check what programs are running.
* Terminate a program.
* Send a message to PCs.

## Control Flow
* User adds IP addresses and name of the PCs.
* User selects the added PC and get the status that it is ON or OFF.
* If it is ON, user select the options(Take a screenshot, Turn off, Running programs, Terminate a program, Send message).
* If it is OFF, just shows the PC is currently OFF.
* User also can delete or modify the added PCs.

## Implementation

### Model
* Pclist.swift
* Status.swift

### View
* PcUITableView
* StatusUIView

### Controller
* PcUITableViewController
* StatusUIViewController
