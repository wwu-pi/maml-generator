package de.wwu.maml.maml2md2.rules.view

import de.wwu.maml.dsl.maml.ParameterConnector
import de.wwu.maml.dsl.mamldata.Boolean
import de.wwu.maml.dsl.mamldata.CustomType
import de.wwu.maml.dsl.mamldata.Date
import de.wwu.maml.dsl.mamldata.DateTime
import de.wwu.maml.dsl.mamldata.Enum
import de.wwu.maml.dsl.mamldata.File
import de.wwu.maml.dsl.mamldata.Float
import de.wwu.maml.dsl.mamldata.Integer
import de.wwu.maml.dsl.mamldata.Time
import de.wwu.maml.dsl.mamlgui.Aggregator
import de.wwu.maml.dsl.mamlgui.Attribute
import de.wwu.maml.dsl.mamlgui.ComputationOperator
import de.wwu.maml.dsl.mamlgui.Filter
import de.wwu.maml.dsl.mamlgui.Label
import de.wwu.maml.dsl.mamlgui.Validator
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.model.DataType2ModelElement
import de.wwu.md2.framework.mD2.BooleanInput
import de.wwu.md2.framework.mD2.DateInput
import de.wwu.md2.framework.mD2.DateTimeInput
import de.wwu.md2.framework.mD2.IntegerInput
import de.wwu.md2.framework.mD2.NumberInput
import de.wwu.md2.framework.mD2.OptionInput
import de.wwu.md2.framework.mD2.TextInput
import de.wwu.md2.framework.mD2.TextInputType
import de.wwu.md2.framework.mD2.TimeInput
import de.wwu.md2.framework.mD2.ViewGUIElement
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class Attribute2ViewElement extends Elem2Elem {
	
	public static final String ruleID = "Attribute->ViewGUIElement"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override sourceToTarget() {
		throw new UnsupportedOperationException("To be used with specific attribute")
	}
	
	/**
	 * Dependencies:
	 * - DataType
	 */
	def Iterable<ViewGUIElement> sourceToTarget(ParameterConnector src, boolean editable) {
		val target = src.targetElement
		switch (target) {
			Label: return newArrayList(target.transformLabel)
			Attribute: return newArrayList(target.transformAttribute(src, editable))
			ComputationOperator: return null // TODO
			Filter: return null // TODO
			Aggregator: return null // TODO
			Validator: return null // TODO
		}
		 
	}
	
	override def targetToSource() {
		throw new UnsupportedOperationException("MD2 to MAML currently unsupported")
	}
	
	def transformLabel(Label label){
		val corr = label.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.label) as de.wwu.md2.framework.mD2.Label
		
		viewElem.name = label.toUniqueName(label.description ?: "label", 15) // TODO better way to name label
		viewElem.text = label.description
		
		return viewElem
	}
	
	def ViewGUIElement transformAttribute(Attribute attr, ParameterConnector src, boolean editable){
		switch attr.type {
			Boolean: return attr.createBooleanInputField(src, editable)
			Integer: return attr.createIntegerInputField(src, editable)
			Float: return attr.createNumberInputField(src, editable)
			de.wwu.maml.dsl.mamldata.String: return attr.createTextInputField(src, editable)
			Date: return attr.createDateInputField(src, editable)
			DateTime: return attr.createDateTimeInputField(src, editable)
			Time: return attr.createTimeInputField(src, editable)
			File: return attr.createTimeInputField(src, editable)
			Enum: return attr.createOptionInputField(src, editable)
			CustomType: return attr.createCustomTypeField(src, editable)
			// TODO collection type: repeat
		}
	}
	
	def createTextInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.textInput) as TextInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		viewElem.defaultValue = ""
		viewElem.type = TextInputType.INPUT
		
		return viewElem
	}
	
	def createBooleanInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.booleanInput) as BooleanInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		viewElem.defaultValue = "false"
		
		return viewElem
	}
	
	def createIntegerInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.integerInput) as IntegerInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		viewElem.defaultValue = 0
		
		return viewElem
	}
	
	def createNumberInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.numberInput) as NumberInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		viewElem.defaultValue = 0.0
		
		return viewElem
	}
	
	def createDateInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.dateInput) as DateInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		
		return viewElem
	}
	
	def createDateTimeInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.dateTimeInput) as DateTimeInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		
		return viewElem
	}
	
	def createTimeInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.timeInput) as TimeInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		
		return viewElem
	}
	
	def createOptionInputField(Attribute attr, ParameterConnector src, boolean editable){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.optionInput) as OptionInput
		
		viewElem.name = attr.toUniqueName(attr.description.allowedAttributeName + "Field")
		viewElem.labelText = src.getHumanCaption
		viewElem.isDisabled = !editable
		viewElem.defaultValue = (attr.type as Enum).values.get(0)?.value
		viewElem.enumReference = attr.type.getOrCreateCorrModelElement(DataType2ModelElement.ruleID)?.targetElement as de.wwu.md2.framework.mD2.Enum
		
		return viewElem
	}
	
	def createCustomTypeField(Attribute attr, ParameterConnector src, boolean editable){
		// Custom type transformed to label, nested attributes to be shown/edited are already contained in the list 
		
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.label) as de.wwu.md2.framework.mD2.Label
		
		viewElem.name = attr.toUniqueName(attr.description ?: "label", 15) // TODO better way to name label
		viewElem.text = src.getHumanCaption
		
		return viewElem
	}
}