//
//  DocumentationMain.h
//  Petri Net Editor
//
//  Created by Mathijs Saey on 26/04/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

/**
@mainpage
@section Introduction
 This is the main Documentation page of the Petri Net Editor. This documentation was made to make it easier for any developer to understand and expand the Petri Net Editor. The original code of this project was written by Mathijs Saey as part of his 3rd bachelor project at the VUB. This code was based on the kernel provided by Nicolas Cardozo. This project strives to provide the user with a visual representation of context oriented systems at runtime. This visual representation is based on general Petri Nets with inhibitor arcs. 
 The documentation of this project is made by doxygen and thus all documentation comments are made according to the doxygen standard.
 The full project can be found on github at: https://github.com/mathsaey/Petri-Net-Editor 
 
 
@section Overview
 The main point of this documentation is to provide an overview of all the classes in the system. All the classes can be found in the Classes section. The kernel classes are not documented but are not omitted so that a user of this documentation can still view the public methods and members as well as their inheritance graphs.
 
 The constants that are used throughout the code can be found in the PNEConstants module found in the modules section. These constants don't influence the working of the code but can be used to fine tune the behaviour of the Petri Net drawing.
 
 Somebody new to the code could start by looking at the PNEView class. The PNENodeView class and it's subclasses should be your next focus. Knowing these 4 classes should be enough to get a basic sense of the inner workings of the product.
 
*/