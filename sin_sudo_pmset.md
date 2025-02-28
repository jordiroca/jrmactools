# **Ejecutar `pmset` sin contraseña sudo**
1. **Abrir archivo `sudoers`**:
   ```bash
   sudo visudo
   ```
2. **Añadir al final** (siendo `nombre_usuario` el nombre de usuario macOS):
   ```
   nombre_usuario ALL=(ALL) NOPASSWD: /usr/bin/pmset
   ```

## **¿Qué hace?**
- Permite a tu usuario ejecutar `/usr/bin/pmset` **sin contraseña ni sudo**.
- **Sólo** para `pmset`
