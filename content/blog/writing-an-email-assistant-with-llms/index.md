---
title: Prioritizing your email inbox with an LLM
date: "2024-03-28T12:00:00.000Z"
description: "Learn how to make an application that uses AI to prioritize your email inbox, using the Gmail API and prompt chaining with ChatGPT."
---

- [Introduction](#introduction)
- [Demo](#demo)
- [How does it work?](#how-does-it-work)
- [Prompt writer](#prompt-writer)
- [Security & privacy](#security--privacy)
- [Future enhancements](#future-enhancements)
- [Conclusion](#conclusion)

## Introduction

We've all heard about the new developments in AI lately. Many of us have asked questions to ChatGPT and found it really helpful. But how can you integrate AI with business applications, so that it helps you complete tasks — without having to switch to the ChatGPT tab in your browser?

To help myself learn more, I've created an AI-based app that will deal with that great problem of the modern era: too many emails in your inbox. This app reviews the unread emails in your Gmail account, and ranks them according to criteria that you can customize, and helps prioritize which ones need your attention, and which ones don't.

I'm sharing this project in the hopes that it'll help people learn a bit more about how AIs actually work — and how to use them to be more productive, and automate the tedious stuff. Although there is a lot of hype about AI right now, I think we'll only hear more about it in the future, so this is also a great way to familiarize yourself with the subject.

This app involves some programming with Python, but even if you're not familiar with coding, I think you might find it interesting. I'll also say, if you're not a developer, there's never been a better time to learn how to program. You can ask tools like ChatGPT to help you write and understand how code works



## Demo

Let's dive in to the application.

I've given this app the name of Inbox Eagle — and yes, the name and the logo are AI-generated, in case you can't tell.

We'll enter the number of days' of emails that we want to review, and click the “Evaluate” button. I'll just start with one day of emails to try it out. [click button]:


And there it is! We can see that the AI has evaluated each message and listed them in order of importance. To get this info, our Python server is retrieving our email messages, sending them to the AI (in this case, ChatGPT 4 Turbo), and asking for an evaluation of each one's importance. [Show logs next to web UI]

## How does it work?

So, how does this really work? The application code here is surprisingly simple — and the most important parts of it are plain English text.

First, some terminology:

- an **LLM**, or Large Language Model, is a type of AI system that is focused on processing text. Examples include ChatGPT, Claude from Anthropic, or the open-source Llama models.
- an **API**, or Application Programming Interface, is a way for two computer systems to communicate with eachother. A prime example is the web browser on your computer getting data from websites on the internet using an API.

So, here's the flow of the whole “Inbox Eagle” application: [show diagram]

1. Web front-end
2. “Evaluate button” triggers Python server
3. Emails are fetched from the Gmail API
4. A prompt is created (in English text!) that asks the AI to evaluate are messages based on given criteria
    1. We then ask the AI to give us just a numeric ranking based on its evaluation
5. The evaluations are sent back to the front-end

![Inbox Eagle Flowchart](./application-flowchart.png)
*A chart illustrating the workflow of the application*

First, I've gone into my Gmail account to enable API access. The API will allow us to retrieve our unread email messages in the app. [Video of Gmail UI]

Next, I've written a Python script that logs into the Gmail account using those API credentials, and pulls the list of unread messages. [Video of script triggering Gmail login]

This is the scariest-looking code of the whole project — but actually, I asked ChatGPT to generate this, and it wrote about 90% of the code here. [Screenshot of prompt to get code]

So, now this app has access to my email account. We're now going to run two processes: the first is a simple front-end interface to view the emails in our web browser, using a popular system called Node JS. The second is a basic server that communicates with the AI of our choice, running in Python. [Show commands in prompt]

Ok, now we're up and running. [Show webpage]

The web front-end uses one of the most popular frameworks to set up an interactive web page, React.  The web browser then communicates with our back-end Python server, which is enabled by using a Python library called Flask. [Show logos]

While there can be some learning curve to work with these libraries, you can also find templates on the web, and use tools like ChatGPT to more easily learn how to customize them. A few lines of code are enough to create the functionality that we see here. [Show code, with function calls mapped to the steps from the diagram]

The heart of our app is in step 4, where the back-end Python code asks the LLM to evaluate our emails, and determine their importance. [Highlight get_message_evaluation function]

So let's dive into that!

## Prompt writer

For each email we retrieved from the Gmail API, we pass the message into this Python function we wrote called “get message evaluation”. This function is responsible for creating a prompt, which is a message in English that we send to ChatGPT. We then call the ChatGPT API and get the AI-generated response.

The cool thing about this is that we can customize our prompt however we want, just by writing in here. So if I say, prioritize messages that are related to pizza, and then re-run the evaluation… [show evaluation]

Great, now I have an AI assistant who loves pizza.

Taking this more seriously, you could apply this to a lot of different use cases. For example, suppose you get a lot of emails at work. You could tell this prompt to prioritize the emails where the sender is asking you for help with something, or prioritize emails where the sender says they need an urgent response. The possibilities are really endless to customize this.

### Evaluation

Now you may notice that these evaluations messages do contain a rating, but that rating isn’t always formatted the same way. For example, this one has the rating at the end of the text, while another one shows the rating in a 1/10 format.

For the purpose of our app, we do want to get the numeric rating, in addition to the evaluation message, so that we can rank our emails easily.

Using traditional programming techniques, it could be quite tricky to extract this rating. But there’s an easy way to solve this: use AI again!

After we receive this full evaluation message from ChatGPT, we then send another request to our LLM, this time with a different prompt that simply says:

> "Take the importance level from the evaluation and return it. Return only the number, and do not add any text, words, or punctuation."

Now, our LLM is smart enough to find the number that matters from the evaluation text, and return the clean, numeric rating.

This two-step tactic illustrates a helpful way to approach the current generation of AI models: they do better when you break down problems into specific sub-steps. In this case, we first ask the LLM to write an evaluation, and then we ask it to extract the numeric rating from the evaluation, which is simpler for the LLM to handle, compared to telling it to do both tasks in a single prompt.

## Security & privacy

A quick word about security and privacy.

When you send your personal or business information to an AI provider, there are 2 things that should be considered:

1. Access to your data
2. Training on your data

The great thing about writing your own assistant, as shown here, is that you choose the backend LLM provider. You can use a big provider like OpenAI or Anthropic (and review their data policies), or even run an LLM on your own machine.

## Future enhancements

This is a demonstration of one way to use AI in your daily workflow, but there are a ton of additional features you could add here.

For example, you could use the Gmail API to label important emails in your inbox, adding a label that says “Important” to emails that rank 8 to 10 here. Then you could tag emails that were ranked only a 1 or 2 with a “Not Important” label. Then when you get to your Gmail account, you could see at a glance which messages to prioritize.

Another idea, for those of us who want to spend less time in front of the computer screen, would be to send the results of this process into a Text To Speech model. You could then listen to the app read out loud the most important emails, while you clean your house, go on a walk, or whatever. So imagine your inbox basically turned into a podcast.

## Conclusion

I wanted to show that making your own workflow that uses AI isn’t as hard as you might think. There are a ton of commercial products coming out every day that use AI models, including some for email management, and many of them might be very helpful. But it’s also valuable to be able to make your own app using a little bit of code, and a little bit of AI prompting. This gives you more control over how your data is used, and lets you customize the process to work better for your specific use case.

Zooming out a little, I think one thing to keep in mind is that these AI tools are only going to keep getting better from here. Although that can be a little scary, as the unknown always is, by diving in and trying out these systems, you can start to understand how they work — what they’re good at, and not so good at. The goal shouldn’t be to replace people with AI, but to use AI to help us focus on the things that really matter — which might not be filtering out the noise in your email inbox!

I’d love to hear any feedback or questions you have, please hit me up. It would really mean a lot to me. And if you have any ideas for some kind of project and  you’re wondering if AI could help with it, let me know! I’d love to discuss and potentially collaborate.

Until then, keep on learning!