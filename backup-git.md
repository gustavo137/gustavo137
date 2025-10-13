#!/bin/bash
set -e

# Nuevo remoto (repositorio totalmente tuyo en GitHub)
```bash
NEW_REMOTE="git@github.com:gustavo137/my-new-repo.git"
```
# 1. Agregar nuevo remoto
```bash
git remote add backup "$NEW_REMOTE"
```
# 2. Fetch de todos los remotos existentes
```bash
git fetch --all
```
# 3. Crear ramas locales para todas las ramas remotas
```bash
for branch in $(git branch -r | grep -v 'HEAD' | grep -v '\->'); do
    git branch --track "${branch#*/}" "$branch" 2>/dev/null || true
done
```

# 4. Push de todas las ramas al nuevo remoto
git push backup --all

# 5. Push de todos los tags
```bash
git push backup --tags
```
echo " Migración completa. Revisa tu nuevo repositorio en GitHub."
echo "Opcional:
```bash
git remote remove origin && git remote rename backup origin
```

# 6. Eliminar el remoto original (opcional)
```bash
git remote remove mine
git remote remove origin
```
# 7 . Renombrar el remoto de backup a origin (opcional)
git remote rename backup origin

