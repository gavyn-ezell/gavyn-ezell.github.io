---
layout: post
title: "1D Perlin Noise: Understanding the Algorithm and a Basic Implementation"
date: 2025-10-07
description: a short piece on 1D perlin noise
tags: procedural-generation math algorithms
thumbnail: assets/img/1d-perlin-article/cover.png
categories:
featured: false
---

## Table of Contents

- [Intro](#why-i-wrote-this-article)
- [What is Perlin Noise?](#what-is-perlin-noise)
- [The Perlin Noise Function](#the-perlin-noise-function)
  - [Function Overview](#function-overview)
  - [The Hash Function](#the-hash-function)
    - [Purpose of the Hash Function](#purpose-of-the-hash-function)
    - [Picking a Hash Function](#picking-a-hash-function)
    - [Code Starts Here](#code-starts-here)
    - [Hash Function Code](#hash-function-code)
  - [The Lerp Function](#the-lerp-function)
    - [Lerp Function Code](#lerp-function-code)
  - [The Fade Function](#the-fade-function)
    - [Fade Function Code](#fade-function-code)
  - [Final Result](#final-result)
- [Full Code Sample](#full-code-sample)
- [Conclusion](#conclusion)
- [Resources](#resources)

## Intro

After watching this [talk](https://www.youtube.com/watch?v=Z8mAN378kIw) about perlin noise applications, I sought to build a 1D perlin noise visualizer to better understand the algorithm before moving onto 2D and 3D.

I wrote this article to test to my understanding and help others trying to learn as well.

You can check out a visualizer I built with Godot [here](https://gezell.itch.io/fractal-noise-visualizers), with the full source repo available [here](https://github.com/gavyn-ezell/fractal-noise-visualizers/).

## What is Perlin Noise?

Perlin noise is a type of [gradient noise](https://en.wikipedia.org/wiki/Gradient_noise) that is widely used in game development for procedural generation of worlds and textures.

{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/mc.png" class="img-fluid rounded z-depth-1" %}

**_Noise_** can be thought of as a random scramble of values (like static on a TV). **_Gradient noise_** just aims for a more coherent scramble. Ken Perlin's original motivation for creating the algorithm was to provide better looking visual effects for movies.

A perlin noise function returns values within the range [-1, 1]. These images help visualize noise by coloring pixels white and black along this range, with a value of -1 being colored white, 1 being black, and anywhere in between is a weighted grey mixture.

{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/noise-comparison.png" class="img-fluid rounded z-depth-1" %}

> One simple application using these noise images is using them as [height maps](https://en.wikipedia.org/wiki/Heightmap) for generating 3D terrain in a video game

---

## The Perlin Noise Function

Simply put:

**A 1D perlin noise function takes a real number, _x_, as input, then returns a noise value from [-1, 1].**

It is important to understand that a 2D perlin noise function receives an _x_ and a _y_ as input, 3D perlin noise receives an _x_, _y_, and _z_, and so on as the dimensions increase. Regardless of the number of dimensions, the actual function will always return a value from [-1, 1].

### Function Overview

Written below is the high level form of the noise function we are about to implement. It may seem a little confusing but we'll build intuition for what each function is doing and how they are implemented.

{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/perlin-overview.webp" class="img-fluid rounded z-depth-1" %}

> If you wanna jump to the section in the article where I actually start showing code, click [here](#code-starts-here). You can also check out the `perlin1d()`function in this class I wrote for my visualizer [here](https://github.com/gavyn-ezell/fractal-noise-visualizers/blob/master/fractal.gd).

### The Hash Function

#### Purpose of the Hash Function

One property of the 1D perlin noise function, is that that every integer value on our 1D number line must have an assigned noise value in the range [-1, 1].

Using the right hash function helps us accomplish this. Hash functions are deterministic - the same integer input will always produce the same output.

Take a look at this graph that plots noise value points at each integer _x_ on the horizontal x axis. This was accomplished using a hash function.
{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/noise.webp" class="img-fluid rounded z-depth-1" %}

> Something that could help build intuition here is imagining you're playing an open world, procedurally-generated game where your player can move through mountainous terrain. Say your player moves from chunk A, then moves very far to chunk Z. The finally moves all the way back to chunk A. We ideally want to render the same mountainous terrain we originally saw, so we need a deterministic and efficient function for recalculating the same mountains.

#### Picking a Hash Function

One easy hash function we can use, inspired by Ken Perlin's published code, utilizes a have uniformly distributed 256 length array with distinct values between 0-256 at each index.

Then when when we have an input integer _x_, we simply index into the array. This will give us an integer in the range [0, 256] which we can the perform a **min-max normalization** to get our final noise value between [-1, 1]

#### Code Starts Here

#### Hash Function Code

```python
p = [151,160,137,91,90,15, 0, ...] # this has all the distinct integers between 0 and 255

def hash(x: int):
    # indices outside our array length can just wrap around through modulo
    h = p[x % 256]

    start = -1.0
    end = 1.0
    # get our our noise value from somewhere between [-1, 1]
    final_noise = start + (h / 255.0)*(end-start)
    return final_noise
```

### The Lerp Function

Perlin noise uses what's called **linear interpolation**, or, _lerp_, to calculate noise values **between** the surrounding integer's noise values

Say `1.6` was our input _x_ to the perlin noise function. Since we know what noise values exist at `1.0` and `2.0` through our hash function, we can linearly interpolate between these values to get our final result.

#### Lerp Function Code

```python
def lerp(start, end, t): #t, is our interpolation factor
    return start + t*(end-start)

def perlin(x):
    # 1. get surrounding integers
    floor_x = floor(x)
    ceil_x = ceil(x)

   # 2. get noise values at these integers
    floor_noise = hash(floor_x)
    ceil_noise = hash(ceil_x)

    #3. get interpolation factor
    t = x - floor_x # gives us some value in [0.0, 1.0]

    #4. interpolate to get a final noise value
    return lerp(floor_noise, ceil_noise, t)

perlin(1.6)

```

Using this code and visualizing it will give us this:

{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/noise-16.webp" class="img-fluid rounded z-depth-1" %}

And here is a fully graphed version:
{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/lerp.png" class="img-fluid rounded z-depth-1" %}

### The Fade Function

_Isn't perlin noise is supposed to be smooth? Why is this graph jagged?_

The final step to smoothing out this curve, is using a **fade function** or **easing function** on the interpolation factor _t_.

By using a **fade function**, we modify the interpolation factor to create smoother looking transitions between our lerp values.

There are all types of easing functions to choose from and you can check them out [here](https://easings.net/). For this article, we will be using [smoothstep](https://en.wikipedia.org/wiki/Smoothstep) as our chosen **fade function**.

#### Fade Function Code

```python
def fade(t):
    # uses smoothstep
    return t * t * (3.0 - 2.0 * t)

def lerp(start, end, t): #t, is our interpolation factor
    return start + t*(end-start)

def perlin(x):
    # 1. get surrounding integers
    floor_x = floor(x)
    ceil_x = ceil(x)

   # 2. get noise values at these integers
    floor_noise = hash(floor_x)
    ceil_noise = hash(ceil_x)

    #3. get interpolation factor
    t = x - floor_x # gives us some value in [0.0, 1.0]

    #4. interpolate to get a final noise value
    return lerp(floor_noise, ceil_noise, fade(t))

perlin(1.6)

```

### Final Result

And here's what that looks like graphed out:
{% include figure.liquid loading="eager" path="assets/img/1d-perlin-article/final.png" class="img-fluid rounded z-depth-1" %}

And that's it! We've covered the the basics of 1D perlin noise.

The visualizer linked at the top of this article shows some extra parameters which is actually for **fractal noise**, which I will also be writing a shorter followup article on. It's essentially multiple layers of perlin noise summed together with each layer being slightly modified

## Full Code Sample

```python
#a scrambled array of distinct values from 0-255
p = [ 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161,1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	]
def hash(x: int):
    # indices outside our array length can just wrap around through modulo
    h = p[x % 256]

    start = -1.0
    end = 1.0
    # calculate our final noise value between [-1, 1]
    final_noise = start + (h / 255.0)*(end-start)
    return final_noise

def lerp(start, end, t): #t, is our interpolation factor
    return start + t*(end-start)

def perlin(x):
    # 1. get surrounding integers
    floor_x = floor(x)
    ceil_x = ceil(x)

   # 2. get noise values at these integers
    floor_noise = hash(floor_x)
    ceil_noise = hash(ceil_x)

    #3. get interpolation factor
    t = x - floor_x # gives us some value in [0.0, 1.0]

    #4. interpolate to get a final noise value
    return lerp(floor_noise, ceil_noise, t)


```

## **Conclusion**

> _Knowing is half the battle!_

I didn't realize how half baked my understanding of the perlin noise algorithm was until working through the implementation details and building a visualizer. Going to try and build a better habit of reading --> doing when learning this kind of stuff...

~gezell

{% include figure.liquid loading="eager" path="assets/img/monkey.png" class="img-fluid rounded z-depth-1" %}

## **Resources**

Listed below are some really cool resources that I have found and categorized while trying to learn perlin noise.

### Videos, Papers, Articles

- [Understanding Perlin Noise](https://adrianb.io/2014/08/09/perlinnoise.html) - A straightforward article going through the perlin noise algorithm

- [CMSC 425: Procedural Generation: 1D Perlin Noise](https://www.cs.umd.edu/class/spring2018/cmsc425/Lects/lect12-1d-perlin.pdf) - Some lecture notes from the University of Maryland

- [Improved Noise Implementation](https://mrl.cs.nyu.edu/~perlin/noise/) - The original code written by Ken Perlin for 3D Perlin Noise

### Practical Applications of Noise

- [Shader written by Inigo Quilez](https://www.shadertoy.com/view/MdX3Rr) - A shader that produces really nice looking scenic shot through perlin generated

- [Math for Game Programmers Part 4 Digging with Perlin Worms](https://www.youtube.com/watch?v=Z8mAN378kIw&t=1357s) - Hidden gem GDC talk sharing perlin noise applications in 1D, 2D, and 3D

- [The Math Behind the Best-Selling Games: Perlin Noise](https://www.youtube.com/watch?v=MMj3WU4gORI) - Informative video essay sharing how important and widely used perlin noise is in games
