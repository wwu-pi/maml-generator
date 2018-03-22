package de.wwu.maml.maml2md2.rules.view

import de.wwu.maml.dsl.maml.ParameterConnector
import de.wwu.maml.dsl.mamlgui.Aggregator
import de.wwu.maml.dsl.mamlgui.Attribute
import de.wwu.maml.dsl.mamlgui.ComputationOperator
import de.wwu.maml.dsl.mamlgui.Filter
import de.wwu.maml.dsl.mamlgui.Label
import de.wwu.maml.dsl.mamlgui.Validator
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.md2.framework.mD2.ViewGUIElement
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*
import de.wwu.maml.maml2md2.rules.model.DataType2ModelElement

class Attribute2ViewElement extends Elem2Elem {
	
	public static final String ruleID = "Attribute->ViewElement"
	
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
			Attribute: return newArrayList(target.transformAttribute(src))
			ComputationOperator: return null // TODO
			Filter: return null // TODO
			Aggregator: return null // TODO
			Validator: return null // TODO
			// TODO others
		}
		 
	}
	
	override def targetToSource() {
		throw new UnsupportedOperationException("MD2 to MAML currently unsupported")
	}
	
	def transformLabel(Label label){
		val corr = label.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.label) as de.wwu.md2.framework.mD2.Label
		
		viewElem.name = label.description?.allowedAttributeName.substring(0, 10) ?: "label" // TODO better way to name label
		viewElem.text = label.description
		
		return viewElem
	}
	
	def transformAttribute(Attribute attr, ParameterConnector src){
		// Get type
		val type = attr.type
		
		switch type{
			de.wwu.maml.dsl.mamldata.Enum: return attr.createOptionField(src)
		}
	}
	
	def createOptionField(Attribute attr, ParameterConnector src){
		val corr = attr.getOrCreateCorrModelElement(ruleID)
		val viewElem = corr.getOrCreateTargetElem(targetPackage.optionInput) as de.wwu.md2.framework.mD2.OptionInput
		
		viewElem.name = attr.description.allowedAttributeName + "Field"
		viewElem.labelText = src.getHumanCaption
		viewElem.defaultValue = (attr.type as de.wwu.maml.dsl.mamldata.Enum).values.get(0)?.value
		viewElem.enumReference = src.getOrCreateCorrModelElement(DataType2ModelElement.ruleID)?.targetElement as de.wwu.md2.framework.mD2.Enum
		
		return viewElem
	}
}