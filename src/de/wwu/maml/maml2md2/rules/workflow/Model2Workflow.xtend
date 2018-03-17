package de.wwu.maml.maml2md2.rules.workflow

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class Model2Workflow extends Elem2Elem {
	
	public static final String ruleID = "Model->Workflow"
	public static final String ruleIDMD2Model = ruleID + "[MD2Model]"
	public static final String ruleIDPackage = ruleID + "[Package]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create workflow
				val corrW = m.getOrCreateCorrModelElement(ruleIDMD2Model)
				val targetW = corrW.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val corrTargetPackageW = m.getOrCreateCorrModelElement(ruleIDPackage)
				val targetPackageWorkflow = corrTargetPackageW.getOrCreateTargetElem(targetPackage.packageDefinition) as PackageDefinition
				targetPackageWorkflow.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".workflows"
				targetW.package = targetPackageWorkflow
				
				val corrLayerW = m.getOrCreateCorrModelElement(ruleID)
				val targetWorkflowLayer = corrLayerW.getOrCreateTargetElem(targetPackage.workflow) as de.wwu.md2.framework.mD2.Workflow
				targetW.modelLayer = targetWorkflowLayer
				targetModel.getMD2WorkflowResource.contents += targetW
			]
	}
	
	override def targetToSource() {
		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
			.forEach[m |
				val corr = m.getOrCreateCorrModelElement(ruleID)
				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
				sourceModel.MAMLResource.contents += source
				println("Correspondence: " + source + " | " + m)
			]
	}
	
}