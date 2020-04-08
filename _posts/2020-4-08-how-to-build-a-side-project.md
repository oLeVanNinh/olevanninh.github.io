---
title: How To Build A Side Project
tags:
  - random
---

## Why side project?
As a developer, we always need to learn to catch up with the technology which changes every day. Sometimes we can feel overwhelmingly with it, or you can feel boring
when the major job is maintaining the old system that uses the technology of 10 years ago. So it's time you should consider building a side project because of its benefit:

- It makes you feel more interesting about programming, you are free to choose the problem you will solve, the technology stack to solve the problem, no deadline,  pressure from your boss and you can do whatever you want
- You will learn more efficient, learn by doing is one of the most effective ways, you learn automatically, not only by theory but with practice
- The side project is one of the fastest ways to prove your ability when you get an interview
- Maybe you will be famous, who knows, Angular and Vue originally just a side project before it becomes popular

With all of that, we will go through the step to build a side project

## 1. Choose the problem to solve

The easy way to find a problem is "scratch your itch place", you like play lottery, you can build the system to predict the lottery results, you like watching beautiful girls
you can build a system to claw the image from outside internet to you local machine like this  :grin:
![](https://raw.githubusercontent.com/oLeVanNinh/javascipt/master/pupunteer-claw-facebook-images/imge-data/Screenshot%20from%202019-03-10%2021-42-38.png)

<p align="center">
  <strike>
    <small>
    If you are interested, I have written a
    <a href="https://github.com/oLeVanNinh/javascipt/blob/report_december/pupunteer-claw-facebook-images/REAME.md">post</a> about it
    </small>
  </strike>
</p>

Seriously, in my case, I have heard if you know how many time it remained in the day, you will work more effectively because you will feel the time for you is short. But I cannot find any app or extension that meet my need, so I was building a simple page [app](https://count-down-remain-time.herokuapp.com/), host it to Heroku
and combined it with custom tab page URL [extention](https://chrome.google.com/webstore/detail/custom-new-tab-url/mmjbdbjnoablegbkcklggeknkfcjkjia?hl=en), every time I open
a new tab, I will know exactly how much time remains in the day and my problem was solved :blush:

Another way is solving the problem of other people from your friend, coworker or someone else like you can find many ideas on  [Idea Watch](https://www.ideaswatch.com/)

Finally, you can start "reinvent the wheel", by developing the idea from the tutorial or clone from the other and add or custom some features you want.

## 2. Define the success

After knowing what you want to build, it is important to know when it "done". It because without it, you are more likely to fall into a **perfect plan** to build a **perfect app** which is what you quit before you get it done. ~~I myself was like that several time~~.

As a developer, I think you know that there is not thing perfect from scratch, every app we build, it starts with version 1.0. Over time, we improve it and later releases, we upgrade it to version  1.1, 1.2,2.0, ... so on. This is the mindset we will apply for our side project we break it in into small main functions and you can consider your project has done when you finish all that function and you can improve it later if you want. If it is possible, I recommend you divide each function so that you can finish in one or two hours to enhance the chance that you are not quit :grin:

For example, when learning angular and ~~trying to build a chat app that can substitute for my company~~ socket-io to build a real-time application, so I decided to build a
chat app. So I define with a list of the user stories:
- [ ] User can create an account
- [ ] Add support for nicknames.
- [ ] User can create a chat room
- [ ] User can join a chat room
- [ ] Show who’s online.
- [ ] Broadcast a message to connected users when someone send a message in a chat room

After done all of this user stories, I consider that my project have done and maybe upgrade it later if neccessary ~~or I like~~
## 3. Get it done and release it

After all, this is the most funny part, I will tell you how I was building chat app above and what I have learn.

Firstly is choose technology, because during that time I trying to learn Javascript as much as possible and I decided to build a full-stack app with all front-end and back-end so I use MEAN stack although I don't know much about ExpressJS and MongoDB.

The UI was build using from Angular Material, at first it is difficult when working with moongse but it becomes easier later, maybe scope of this user story is
too small :relieved:, when working with back-end, the hardest part is organized folder struct and code.

<div align="center">
  <img src="/img/side_project_post/code_struct.png">
</div>

<p align="center">
<small><i>I was organized code struct like in Rails app</i></small>
</p>

In this part, I almost not follow a specific tutorial, but I find almost information and knowledge specific to help a feature done. From how to use socket client in Angular,
how to setup, connect, create schema with moongse, writing API with NodeJS and Express, ...

After sometimes coding, almost functions had done, not perfect but it works. You can find it in this [repo](https://github.com/oLeVanNinh/chat)

The last step is to introduce your app for your friends, community. ~~I think I too shy to do that~~. To do that, if it is a web application you can host it on a host like
Heroku, if it is an android application, you can build APK and then invite your friend use it. What about iOS, it is better if you upload it on AppStore :grin:
