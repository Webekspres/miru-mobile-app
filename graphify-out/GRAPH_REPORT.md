# Graph Report - .  (2026-07-07)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 14 nodes · 14 edges · 3 communities (2 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d07dc3df`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]

## God Nodes (most connected - your core abstractions)
1. `MyHomePage` - 3 edges
2. `_MyHomePageState` - 3 edges
3. `MyApp` - 2 edges
4. `title` - 1 edges
5. `_counter` - 1 edges
6. `main` - 1 edges
7. `build` - 1 edges
8. `createState` - 1 edges
9. `_incrementCounter` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (3 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.25
Nodes (7): build, _counter, createState, _incrementCounter, main, title, package:flutter/material.dart

### Community 1 - "Community 1"
Cohesion: 0.50
Nodes (4): MyHomePage, _MyHomePageState, State, StatefulWidget

## Knowledge Gaps
- **6 isolated node(s):** `title`, `_counter`, `main`, `build`, `createState` (+1 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MyApp` connect `Community 2` to `Community 0`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **Why does `MyHomePage` connect `Community 1` to `Community 0`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **Why does `_MyHomePageState` connect `Community 1` to `Community 0`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **What connects `title`, `_counter`, `main` to the rest of the system?**
  _6 weakly-connected nodes found - possible documentation gaps or missing edges._