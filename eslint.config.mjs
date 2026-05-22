import js from "@eslint/js";
import globals from "globals";
import {
	defineConfig
} from "eslint/config";

export default defineConfig([
	{
		files: ["**/*.{js,mjs,cjs}"],
		plugins: {
			js
		},
		extends: ["js/recommended"],
		languageOptions: {
			globals: globals.node
		},
		rules: {
			...js.configs.recommended.rules,
			eqeqeq: "error",
			"no-unused-vars": "warn",
			"no-constant-condition": "off",
			"no-constant-binary-expression": "off",
			"no-extra-boolean-cast": "warn",
			"no-undef": "error",
			"no-unreachable": "warn",
			"no-useless-escape": "warn",
			"no-async-promise-executor": "warn",
		}
	},
	{
		files: ["**/*.js"],
		languageOptions: {
			sourceType: "commonjs"
		}
	},
]);