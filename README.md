# Project 0 Spell Points Calculator

A rework of my original Spell Points calculator project. This version is being updated to use Angular as a front-end interface. After angular is implemented the plan is to rework the database connection to utilize Hibernate.

## Features and Requirements

- Angular Front-end
  - With accompanying tests.
- Some sort of Angular logging.
- Hibernate Database Connection
  - With accompanying tests.
- Log4J2
  - With different logs for each section of code.

### Requirement Goals

- Infrastructure
  - Hosted on Azure VM
  - Running a Jenkins pipeline
  - SQL database using Elephant SQL
- Libraries and frameworks
  - Angular
  - Hibernate
  - Log4J2
  
> ## Original Definition
>
> A small console application for tracking spell points in Dungeons and Dragons 5th edition. This application allows you to select your class and level, and then will return you the names of spells you can cast as well as your total spell points. You can then input which spell you would like to cast and it will automatically decrement your points and refresh your spell list to remove any spells you may not be able to cast anymore.
>
> **Features/Reqs**
>
>- User Authentication
>- Stored persistent information
>- JUnit tests
>- Log4j logging
>- Scalability in data storage and UI
