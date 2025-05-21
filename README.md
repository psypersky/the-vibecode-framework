# The VibeCode Framework

Apps that build themselves

## Abstract

A new way of programming requires a new architecture, we all have seen how hard it is for AI to mantain coeherence when building a codebase. This framework is a set of rules designed to optmise context performance in AI models. The main idea is to micro modularize, nothing new, but humans have demostrated to be really bad at this hence AI is too.

Appart from building themselves these apps are AI first, AI should have access to all state of the app by default, should be introspective and be able to read its configuration, it should be self configuring.

Interfaces are dynamic, an AI expresses itself in a canvas without the need of pre-programming it, it can automatically generate graphics, forms for input, images, etc.

## Rules

### Single global State 

Single global state is simple, we can feed it all to the AI.
Every single thing, router, form state, animation state, timers, etc.

A truly View = f(State)

The f(State) didn't mean that the state goes inside the view dipshits

E.g.
```js
const state = {
  currentPage: 'home',
  loginForm: {
    userInput: 'alb',
    userInputIsTouched: true,
    userInputIsFocused: true,
    passwordInput: '',
    ...
  },
  user: {
    username: 'panqueque',
    ....
  },
}

```

But...but...What about if my app growsss in intoo a big app? NO! NO! Shutup! If that happens, congrats! You made it, let your new enginering team figure it out!

But I am a really big company with a really big app. Welcome Sr. Come this way. We have Sub Modules. Keep reading ;).

Some advantages: 

Bug debugging: An error happens somewhere you send the full state of your app to your logger, complete and absolute visibility!

Remote control: Given that the view responds to state, you could trivially implement a remote control of the state hence the app. Image this: A user calls you because the app doesn't work, you login into your admin panel, get control of his app, see his full app state, figure what's happening in real time, fix it and bum, user happy.

Easy to implement complex tasks: Imagine this, you want your AI to give you suggestions based on what you type on every input on your app, imagine the pain of creating a freaking reducer for every single input in the whole APP! NO! Its already there, on the single state, there, done, finito! bye!

### Independent View

AI is really good at vibing UI components, we don't want to manually translate each component into our framework specificities or cause friction for the AI, so components should be pure and automatically binded to state.

```js
// Automatically subscribe to specific state changes and update component on state change
// Ignores all renders from parent components, we don't care about that
export function MyComponent() {
  if (state.user.username) {
    return <div>{state.user.username}</div>
  } else {
    return <div>No user</div>
  }
}

```

This way we can just vibe our whole view either in an AI web interface or directly on our editor.


Actions are just triggered in the components, no logic is executed there.

```js
...
    <div onClick={actions.submitForm()}/>
...

```

There's no need to send the state to the action since all the state is already on our global state

## Inspiration 

The guy that sneezes and expels a new framework
Christian Alfoni
https://christianalfoni.com/
