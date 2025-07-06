# Documentation de l'API CLIMB

L'API CLIMB est une application Flask qui permet de gérer des utilisateurs et des murs d'escalade. Elle inclut des fonctionnalités pour ajouter, récupérer, mettre à jour et supprimer des utilisateurs et des murs.

## Base URL
```
http://<host>:5000
```

---

## Endpoints

### 1. **Accueil**
#### `GET /`
Retourne un message de bienvenue.

**Réponse :**
```json
"Welcome to the CLIMB API!"
```

---

### 2. **Utilisateur**

#### a. **Ajouter un utilisateur**
##### `POST /user/add`
Ajoute un nouvel utilisateur avec un score par défaut.

**Corps de la requête :**
```json
{
    "username": "nom_utilisateur"
}
```

**Réponses :**
- **201 Created** : Utilisateur ajouté avec succès.
- **400 Bad Request** : Le nom d'utilisateur est requis.
- **409 Conflict** : Le nom d'utilisateur existe déjà.

---

#### b. **Récupérer un utilisateur**
##### `GET /user/<string:name>`
Récupère les informations d'un utilisateur par son nom.

**Réponses :**
- **200 OK** : Retourne les informations de l'utilisateur.
- **404 Not Found** : Utilisateur non trouvé.

**Exemple de réponse :**
```json
{
    "id": 1,
    "username": "nom_utilisateur",
    "score": 400
}
```

---

#### c. **Mettre à jour le score d'un utilisateur**
##### `PUT /user/update/<string:name>/<int:wall_id>/<int:success>`
Met à jour le score d'un utilisateur en fonction de son interaction avec un mur.

**Paramètres :**
- `name` : Nom de l'utilisateur.
- `wall_id` : ID du mur.
- `success` : 1 pour succès, 0 pour échec.

**Réponses :**
- **200 OK** : Score mis à jour avec succès.
- **404 Not Found** : Utilisateur ou mur non trouvé.
- **400 Bad Request** : Valeur de succès invalide.

---

#### d. **Récupérer tous les utilisateurs**
##### `GET /user/users`
Retourne la liste de tous les utilisateurs.

**Réponse :**
```json
[
    {"id": 1, "username": "nom_utilisateur", "score": 400},
    {"id": 2, "username": "autre_utilisateur", "score": 300}
]
```

---

### 3. **Mur**

#### a. **Ajouter un mur**
##### `POST /wall/add`
Ajoute un nouveau mur avec une couleur, une localisation et un score par défaut.

**Corps de la requête :**
```json
{
    "color": "blue",
    "location": "zone_1"
}
```

**Réponses :**
- **201 Created** : Mur ajouté avec succès.
- **400 Bad Request** : La couleur et la localisation sont requises.
- **409 Conflict** : Un mur existe déjà à cette localisation.

---

#### b. **Récupérer un mur**
##### `GET /wall/<int:wall_id>`
Récupère les informations d'un mur par son ID.

**Réponses :**
- **200 OK** : Retourne les informations du mur.
- **404 Not Found** : Mur non trouvé.

**Exemple de réponse :**
```json
{
    "id": 1,
    "color": "blue",
    "location": "zone_1",
    "score": 400
}
```

---

#### c. **Récupérer tous les murs**
##### `GET /wall/walls`
Retourne la liste de tous les murs.

**Réponse :**
```json
[
    {"id": 1, "color": "blue", "location": "zone_1", "score": 400},
    {"id": 2, "color": "red", "location": "zone_2", "score": 500}
]
```

---

#### d. **Supprimer un mur**
##### `DELETE /wall/remove/<int:wall_id>`
Supprime un mur par son ID.

**Réponses :**
- **200 OK** : Mur supprimé avec succès.
- **404 Not Found** : Mur non trouvé.

---

#### e. **Compter les murs**
##### `GET /walls/count`
Retourne le nombre total de murs.

**Réponse :**
```json
{
    "total_walls": 5
}
```

---

## Notes
- Les bases de données SQLite sont utilisées pour stocker les utilisateurs et les murs.
- Les journaux des actions sont enregistrés dans le fichier `./data/logs.txt`.
- Les scores des murs sont définis par leur couleur via le dictionnaire `score_colors`.

---

## Initialisation
Lors du démarrage de l'application, les bases de données des utilisateurs et des murs sont initialisées si elles n'existent pas.

**Commandes pour démarrer l'application :**
```bash
python3 main.py
```

---
