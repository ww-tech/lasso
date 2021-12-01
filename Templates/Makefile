TEMPLATES_DIR=~/Library/Developer/Xcode/Templates/File\ Templates
LASSO_TEMPLATES_DIR=Lasso

install:
	@mkdir -p $(TEMPLATES_DIR)
	@rm -fR $(TEMPLATES_DIR)/$(LASSO_TEMPLATES_DIR)
	@cp -R $(LASSO_TEMPLATES_DIR) $(TEMPLATES_DIR)
	@echo "Lasso templates installed successfully!"

uninstall:
	@rm -fR $(TEMPLATES_DIR)/$(LASSO_TEMPLATES_DIR)
	@echo "Lasso templates uninstalled successfully!"
