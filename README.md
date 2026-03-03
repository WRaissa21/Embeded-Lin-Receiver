# Conception d'un Récepteur de Trames LIN

Ce projet, réalisé dans le cadre du cursus **Électronique et Technologies Numériques (ETN4)**, porte sur la conception et l'implémentation d'un circuit numérique dédié à la **réception de trames LIN** (*Local Interconnect Network*). 

L'objectif est d'assurer la réception sérielle de données (vitesse de 19 200 bit/s) issue d'un calculateur automobile, de les filtrer et de les restituer sous forme parallèle (8 bits) à un microprocesseur.

## 🚀 Fonctionnalités
- **Réception sérielle LIN** : Détection du *Synchro Break*, synchronisation d'horloge et désérialisation des octets.
- **Interface Microprocesseur (IM)** : Gestion des échanges de données et de contrôle via un bus bidirectionnel de 8 bits.
- **Filtrage de messages** : Comparaison de l'identifiant de trame avec une adresse de filtrage (`SelAdr`) configurable.
- **Mémorisation par FIFO** : Stockage des octets reçus pour une lecture asynchrone par le processeur.
- **Gestion d'état et d'erreurs** : Signalisation de fin de message (`M.Received`) et détection d'erreurs sur les bits START/STOP.

## 🏗️ Architecture du Système
Le circuit suit une approche **Top-Down** selon la **Méthodologie de Conception de Circuit Électronique (MCCE)**. Il est divisé en trois blocs principaux :

1.  **Interface Microprocesseur** : Automate à 4 états gérant les cycles de lecture (données/état) et d'écriture (filtre).
2.  **Partie Opérative (Récepteur LIN)** : Comprend des compteurs, un registre à décalage et des multiplexeurs pour l'échantillonnage au milieu des bits.
3.  **Unité de Commande (Récepteur LIN)** : Machine à états complexe assurant le séquençage complet de la trame (du *Synchro Break* au *Checksum*).

## 🛠️ Outils et Technologies
- **Langage** : VHDL.
- **CAO** : Suite Siemens (**HDL Designer**, **Precision Synthesis**).
- **Simulation** : **Modelsim**.
- **Cible Matérielle** : FPGA **AMD Xilinx Artix7** (7A35TCPG236).
- **Routage** : **AMD Vivado**.

## 📁 Structure du Dépôt
- `/src` : Contient les descriptions VHDL (`InterfaceMicroprocesseur.vhd`, `Command_Unit_Block.vhd`, etc.).
- `/tb` : Environnement de test et stimuli (`EnvTest_InterfaceMicroprocesseur.vhd`).
- `/doc` : Rapport de conception détaillé et chronogrammes de validation.

## 📊 Résultats et Validation
- **Validation fonctionnelle** : Réussie pour l'ensemble des blocs via simulation Modelsim (échantillonnage précis à 26 µs, désérialisation correcte).
- **Synthèse logique** : L'interface microprocesseur a été synthétisée avec succès, utilisant **9 LUTs** sur Artix7.
- **Limites** : La synthèse physique (placement/rouage) du récepteur LIN complet a rencontré des difficultés dues à la complexité de l'unité de commande.

## 👥 Auteurs

- Raïssa WITANO DANWE
- Mathilde DUMAS
---
*Projet encadré par Sébastien Le Nours - Année académique 2025-2026.*
